// Function to reshape Arabic text for proper rendering
function reshapeArabicText(text) {
    return ArabicReshaper.convert(text);
}

// Function to process input text and generate word list
function processText(text) {
    // Split text into words and count frequency
    const words = text.trim().split(/\s+/);
    const wordFreq = {};

    words.forEach(word => {
        word = reshapeArabicText(word);
        wordFreq[word] = (wordFreq[word] || 0) + 1;
    });

    // Convert to wordcloud2.js format: [[word, freq], ...]
    return Object.entries(wordFreq);
}

// Function to generate word cloud
function generateWordCloud() {
    const text = document.getElementById('textInput').value;
    if (!text) {
        alert('يرجى إدخال نص عربي!');
        return;
    }

    const wordList = processText(text);

    // Word cloud configuration
    const options = {
        list: wordList,
        gridSize: 8,
        weightFactor: 20,
        fontFamily: 'Arial, sans-serif',
        color: 'random-dark',
        backgroundColor: '#fff',
        rotateRatio: 0.5,
        rotationSteps: 2,
        shuffle: true,
        drawOutOfBound: false
    };

    // Generate word cloud
    WordCloud(document.getElementById('cloudCanvas'), options);
}
