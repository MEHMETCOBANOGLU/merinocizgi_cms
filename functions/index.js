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
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const { logger } = require("firebase-functions");

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








/**
 * YENİ FONKSİYON: Oylama Değişikliğinde Seri Puanını Yeniden Hesaplama
 * Bir serinin 'ratings' alt koleksiyonunda bir döküman oluşturulduğunda,
 * güncellendiğinde veya silindiğinde tetiklenir.
 * Ana 'series' dökümanındaki rating istatistiklerini günceller.
 */
exports.recalculateSeriesRating = onDocumentWritten("series/{seriesId}/ratings/{ratingId}", async(event) => {
    // ratingId burada kullanıcının UID'si olacak.
    const seriesId = event.params.seriesId;
    const seriesRef = admin.firestore().collection("series").doc(seriesId);

    logger.info(`Rating değişikliği algılandı. Seri (${seriesId}) için puan yeniden hesaplanıyor.`);

    try {
        // İlgili serinin tüm 'ratings' alt koleksiyonunu çek.
        const ratingsSnapshot = await seriesRef.collection("ratings").get();

        const allDocs = ratingsSnapshot.docs;
        const ratingCount = allDocs.length;

        // Eğer hiç oy kalmadıysa, puanları sıfırla.
        if (ratingCount === 0) {
            logger.info(`Seri (${seriesId}) için hiç oy kalmadı, puanlar sıfırlanıyor.`);
            return seriesRef.update({
                averageRating: 0,
                ratingCount: 0,
            });
        }

        // Tüm puanları topla.
        const totalRatingPoints = allDocs.reduce((sum, doc) => {
            // Her dökümandaki 'rating' alanını toplama ekle.
            // Güvenlik için, eğer 'rating' alanı yoksa veya sayı değilse 0 ekle.
            return sum + (doc.data().rating || 0);
        }, 0);

        // Ortalamayı hesapla ve virgülden sonra bir basamağa yuvarla.
        const averageRating = totalRatingPoints / ratingCount;
        const roundedAverage = Math.round(averageRating * 10) / 10; // Örn: 4.76 -> 4.8

        logger.info(`Hesaplama tamamlandı. Seri (${seriesId}): Puan=${roundedAverage}, Oy Sayısı=${ratingCount}`);

        // Ana seri dökümanını yeni, doğru istatistiklerle güncelle.
        return seriesRef.update({
            averageRating: roundedAverage,
            ratingCount: ratingCount,
        });

    } catch (error) {
        logger.error(`Seri puanı yeniden hesaplanırken hata oluştu (${seriesId}):`, error);
        return null;
    }
});