function generateWordCloud() {
    const container = document.getElementById('wordcloud-container');
    const text = document.getElementById('text-input').value;

    if (!text.trim()) {
        alert('يرجى إدخال نص.');
        return;
    }

    const wordsArray = text.split(/\s+/)
        .filter(word => word.length > 1) // Remove single letters
        .map(word => [word, Math.floor(Math.random() * 50) + 10]); // Random weight

    container.innerHTML = ""; // Clear previous cloud

    WordCloud(container, {
        list: wordsArray,
        fontFamily: 'Amiri, Cairo, Arial, sans-serif',
        gridSize: 10,
        weightFactor: 3,
        backgroundColor: "#f8f9fa",
        color: "random-dark",
        rotateRatio: 0,
        drawOutOfBound: false,
        origin: [container.offsetWidth / 2, container.offsetHeight / 2]
    });
}
