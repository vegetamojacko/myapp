
<script>
  // A simple async function to add a document to the 'car_washes' collection
  async function addCarWash() {
    const { getFirestore, collection, addDoc } = await import("https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js");
    const firestore = getFirestore();
    try {
      const docRef = await addDoc(collection(firestore, "car_washes"), {
        name: "Disoufeng car wash Meadowlands",
      });
      console.log("Document written with ID: ", docRef.id);
    } catch (e) {
      console.error("Error adding document: ", e);
    }
  }

  // Call the function to add the car wash
  addCarWash();
</script>
