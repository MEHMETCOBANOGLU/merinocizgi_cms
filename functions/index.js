const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");


// Firebase Admin SDK'yı başlat
admin.initializeApp();

/**
 * Bir kullanıcıya e-posta adresi üzerinden admin rolü atar.
 * Bu fonksiyon, sadece kimliği doğrulanmış kullanıcılar tarafından çağrılabilir.
 * İlk admini atamak için güvenlik kontrolü geçici olarak devre dışı bırakılabilir.
 */
// const { onDocumentWritten } = require("firebase-functions/v2/firestore");
// const admin = require("firebase-admin");
// const { logger } = require("firebase-functions");

// --- FONKSİYON 1: Admin Rolü Atama ---
// (Bu fonksiyon production-ready, değişiklik gerekmiyor)
exports.addAdminRole = onCall(async(request) => {
    // Sadece admin olanlar bu fonksiyonu çağırabilir
    if (!request.auth || !request.auth.token.admin) {
        throw new HttpsError("permission-denied", "Bu işlemi sadece adminler yapabilir.");
    }
    const email = request.data.email;
    if (!email) {
        throw new HttpsError('invalid-argument', 'E-posta adresi eksik.');
    }
    try {
        const user = await admin.auth().getUserByEmail(email);
        await admin.auth().setCustomUserClaims(user.uid, { admin: true });
        return { message: `Başarılı! ${email} artık bir admin.` };
    } catch (error) {
        logger.error("Admin rolü atama hatası:", error);
        throw new HttpsError("internal", "İşlem sırasında bir hata oluştu.");
    }
});


/**
 * YENİ FONKSİYON 1: BÖLÜM DEĞİŞTİĞİNDE SERİ İSTATİSTİKLERİNİ GÜNCELLEME
 * Bir serinin 'episodes' alt koleksiyonunda bir döküman oluşturulduğunda,
 * güncellendiğinde veya silindiğinde tetiklenir.
 * Üst 'series' dökümanındaki özet sayaçlarını günceller.
 */
exports.updateSeriesStatsOnEpisodeChange = onDocumentWritten("series/{seriesId}/episodes/{episodeId}", async(event) => {
    const seriesId = event.params.seriesId;
    const seriesRef = admin.firestore().collection("series").doc(seriesId);

    try {
        // İlgili serinin tüm bölümlerini tek seferde çek.
        const episodesSnapshot = await seriesRef.collection("episodes").get();

        const totalEpisodes = episodesSnapshot.size;
        const approvedEpisodes = episodesSnapshot.docs.filter(doc => doc.data().status === 'approved').length;
        const hasPublishedEpisodes = approvedEpisodes > 0;

        logger.info(`Seri istatistikleri güncelleniyor (${seriesId}): Toplam=${totalEpisodes}, Onaylı=${approvedEpisodes}`);

        // Üst seri dökümanını yeni sayaçlarla güncelle.
        return seriesRef.update({
            totalEpisodes: totalEpisodes,
            approvedEpisodes: approvedEpisodes,
            hasPublishedEpisodes: hasPublishedEpisodes
        });

    } catch (error) {
        logger.error(`Seri istatistikleri güncellenirken hata oluştu (${seriesId}):`, error);
        return null;
    }
});


/**
 * YENİ FONKSİYON 2: YENİ BÖLÜM İÇİN İNCELEME GÖREVİ OLUŞTURMA
 * 'episodes' alt koleksiyonuna 'pending' durumunda yeni bir döküman eklendiğinde tetiklenir.
 */
exports.createReviewTaskForNewEpisode = onDocumentWritten("series/{seriesId}/episodes/{episodeId}", async(event) => {
    // Sadece yeni bir bölüm oluşturulduğunda ve durumu 'pending' ise çalış.
    if (event.data.before.exists || !event.data.after.exists) return null;

    const episodeData = event.data.after.data();
    if (episodeData.status !== 'pending') return null;

    const seriesId = event.params.seriesId;
    const episodeId = event.params.episodeId;

    // Ana seri bilgilerini al
    const seriesDoc = await admin.firestore().collection("series").doc(seriesId).get();
    if (!seriesDoc.exists) return null;
    const seriesData = seriesDoc.data();

    logger.info(`Yeni bölüm (${episodeId}) için inceleme görevi oluşturuluyor.`);

    // 'reviews' koleksiyonuna her PENDING bölüm için ayrı bir görev ekle.
    // Döküman ID'si, bölümün ID'si ile aynı olacak.
    return admin.firestore().collection("reviews").doc(episodeId).set({
        seriesId: seriesId,
        episodeId: episodeId,
        seriesTitle: seriesData.title,
        episodeTitle: episodeData.title,
        authorName: seriesData.authorName,
        reason: "new_episode_review",
        status: "pending", // Bu görevin durumu
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
});





/////////////////////////////////////////////////////////////////////////



/**
 * FONKSİYON 1: Çizgi Roman (Series) için Puanları Yeniden Hesaplama
 * 'series/{seriesId}/ratings' koleksiyonunda bir değişiklik olduğunda tetiklenir.
 */
exports.recalculateSeriesRating = onDocumentWritten("series/{seriesId}/ratings/{ratingId}", async(event) => {
    const seriesId = event.params.seriesId;
    const collectionPath = "series"; // Bu fonksiyonun çalıştığı koleksiyon

    logger.info(`Rating değişikliği algılandı. TÜR: ${collectionPath}, ID: ${seriesId}`);

    // Geri kalan tüm mantık, jenerik bir fonksiyona devredilecek.
    return _recalculateRating(collectionPath, seriesId);
});


/**
 * FONKSİYON 2: Kitap (Books) için Puanları Yeniden Hesaplama
 * 'books/{bookId}/ratings' koleksiyonunda bir değişiklik olduğunda tetiklenir.
 */
exports.recalculateBookRating = onDocumentWritten("books/{bookId}/ratings/{ratingId}", async(event) => {
    const bookId = event.params.bookId;
    const collectionPath = "books"; // Bu fonksiyonun çalıştığı koleksiyon

    logger.info(`Rating değişikliği algılandı. TÜR: ${collectionPath}, ID: ${bookId}`);

    // Geri kalan tüm mantık, aynı jenerik fonksiyona devredilecek.
    return _recalculateRating(collectionPath, bookId);
});


/**
 * YARDIMCI (JENERİK) FONKSİYON: Puan Hesaplama Mantığı
 * Bu fonksiyon, kod tekrarını önlemek için hem seriler hem de kitaplar tarafından kullanılır.
 * Kendisi bir Cloud Function değildir, sadece bir yardımcıdır.
 */
async function _recalculateRating(collectionPath, contentId) {
    const contentRef = admin.firestore().collection(collectionPath).doc(contentId);

    try {
        const ratingsSnapshot = await contentRef.collection("ratings").get();
        const allDocs = ratingsSnapshot.docs;
        const ratingCount = allDocs.length;

        if (ratingCount === 0) {
            logger.info(`İçerik (${contentId}) için hiç oy kalmadı, puanlar sıfırlanıyor.`);
            return contentRef.update({
                averageRating: 0,
                ratingCount: 0,
            });
        }

        const totalRatingPoints = allDocs.reduce((sum, doc) => sum + (doc.data().rating || 0), 0);
        const averageRating = totalRatingPoints / ratingCount;
        const roundedAverage = Math.round(averageRating * 10) / 10;

        logger.info(`Hesaplama tamamlandı. İçerik (${contentId}): Puan=${roundedAverage}, Oy Sayısı=${ratingCount}`);

        return contentRef.update({
            averageRating: roundedAverage,
            ratingCount: ratingCount,
        });

    } catch (error) {
        logger.error(`Puan yeniden hesaplanırken hata oluştu (${contentId}):`, error);
        return null;
    }
}










//////////////////////////////////////////////


/**
 * YENİ FONKSİYON: Takip Etme İşlemi
 * Bir kullanıcı, 'following' koleksiyonuna yeni bir döküman eklediğinde tetiklenir.
 */
exports.onUserFollow = onDocumentWritten("users/{followerId}/following/{followedId}", async(event) => {
    const followerId = event.params.followerId;
    const followedId = event.params.followedId;

    // --- Takip etme (döküman oluşturulduğunda) ---
    if (event.data.after.exists && !event.data.before.exists) {
        logger.info(`Kullanıcı ${followerId}, ${followedId}'ı takibe aldı. İşlemler başlıyor.`);

        // 1. Takip edilen kişinin 'followers' koleksiyonuna, takip edeni ekle.
        const followerDoc = await admin.firestore().collection("users").doc(followerId).get();
        const followerData = followerDoc.data() || {};
        await admin.firestore()
            .collection("users").doc(followedId)
            .collection("followers").doc(followerId)
            .set({
                followerName: followerData.mahlas || 'Bilinmeyen',
                followerImageUrl: followerData.profileImageUrl || null,
                followedAt: admin.firestore.FieldValue.serverTimestamp()
            });

        // 1.2 Takip eden kişinin 'following' koleksiyonuna, takip edeni ekle.
        const followedDoc = await admin.firestore().collection("users").doc(followedId).get();
        const followedData = followedDoc.data() || {};
        await admin.firestore()
            .collection("users").doc(followerId)
            .collection("following").doc(followedId)
            .set({
                followedName: followedData.mahlas || 'Bilinmeyen',
                followedImageUrl: followedData.profileImageUrl || null,
                followedAt: admin.firestore.FieldValue.serverTimestamp()
            });


        // 2. İlgili sayaçları güncelle. (Atomik işlem için 'increment')
        const increment = admin.firestore.FieldValue.increment(1);
        const followerRef = admin.firestore().collection("users").doc(followerId);
        const followedRef = admin.firestore().collection("users").doc(followedId);

        await followerRef.update({ followingCount: increment });
        await followedRef.update({ followersCount: increment });

        return logger.info("Takip işlemi başarıyla tamamlandı.");
    }

    // --- Takipten Çıkma (döküman silindiğinde) ---
    if (!event.data.after.exists && event.data.before.exists) {
        logger.info(`Kullanıcı ${followerId}, ${followedId}'ı takipten çıktı. İşlemler başlıyor.`);

        // 1. Takip edilen kişinin 'followers' koleksiyonundan, takip edeni sil.
        await admin.firestore()
            .collection("users").doc(followedId)
            .collection("followers").doc(followerId)
            .delete();

        // 2. İlgili sayaçları güncelle.
        const decrement = admin.firestore.FieldValue.increment(-1);
        const followerRef = admin.firestore().collection("users").doc(followerId);
        const followedRef = admin.firestore().collection("users").doc(followedId);

        await followerRef.update({ followingCount: decrement });
        await followedRef.update({ followersCount: decrement });

        return logger.info("Takipten çıkma işlemi başarıyla tamamlandı.");
    }

    return null;
});






/**
 * YENİ FONKSİYON: Okuma Olayı Gerçekleştiğinde Görüntülenme Sayısını Artırma
 * 'readEvents' koleksiyonuna yeni bir döküman eklendiğinde tetiklenir.
 * İlgili serinin ve bölümün 'viewCount' sayaçlarını bir artırır.
 */
exports.incrementViewCounts = onDocumentWritten("readEvents/{eventId}", async(event) => {
    // Sadece yeni bir döküman oluşturulduğunda çalış.
    if (!event.data.after.exists || event.data.before.exists) {
        return null;
    }

    const eventData = event.data.after.data();
    const { userId, seriesId, episodeId } = eventData;

    // Gerekli veriler yoksa işlemi durdur.
    if (!userId || !seriesId || !episodeId) {
        logger.error("Okuma olayında eksik veri: ", event.data.after.id);
        return null;
    }

    // Hem seri hem de bölüm dökümanlarının referanslarını al.
    const seriesRef = admin.firestore().collection("series").doc(seriesId);
    const episodeRef = seriesRef.collection("episodes").doc(episodeId);

    // Sayaçları bir artırmak için 'increment' operatörünü kullan.
    // Bu, birden fazla isteğin aynı anda gelmesi durumunda bile doğru sonucu verir.
    const increment = admin.firestore.FieldValue.increment(1);

    try {
        // İki güncellemeyi de bir batch işlemi içinde yapmak en iyisidir.
        const batch = admin.firestore().batch();

        batch.update(seriesRef, { viewCount: increment });
        batch.update(episodeRef, { viewCount: increment });

        await batch.commit();

        logger.info(`Görüntülenme sayısı artırıldı. Seri: ${seriesId}, Bölüm: ${episodeId}`);
        return null;

    } catch (error) {
        logger.error(`Görüntülenme sayısı artırılırken hata oluştu:`, error);
        return null;
    }
});