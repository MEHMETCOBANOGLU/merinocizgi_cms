const admin = require("firebase-admin");
const fs = require("fs");
const serviceAccount = require("./serviceAccountKey.json");

const collectionName = process.argv[2];
const subCollection = process.argv[3];

if (!collectionName) {
    console.error("Lütfen bir koleksiyon adı girin. Örn: node export.js users [subCollection]");
    process.exit(1);
}

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const data = {
    [collectionName]: {} };

async function exportCollection() {
    const snapshot = await db.collection(collectionName).get();

    for (const doc of snapshot.docs) {
        const docData = doc.data();

        if (subCollection) {
            const subSnap = await db
                .collection(collectionName)
                .doc(doc.id)
                .collection(subCollection)
                .get();

            const subData = {};
            subSnap.forEach(subDoc => {
                subData[subDoc.id] = subDoc.data();
            });

            docData[subCollection] = subData;
        }

        data[collectionName][doc.id] = docData;
    }

    fs.writeFileSync("firestore-export.json", JSON.stringify(data, null, 2));
    console.log("✅ JSON dosyası oluşturuldu: firestore-export.json");
}

exportCollection().catch(err => {
    console.error("❌ Hata:", err);
});