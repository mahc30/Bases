const mongoose = require('mongoose');

mongoose.connect('mongodb://localhost/myproject', {
    useCreateIndex: true,
    useNewUrlParser: true,
    useFindAndModify: false,
    useUnifiedTopology: true
})
    .then(db => console.log('DB CONNECTED'))
    .catch(db => console.log('nel'));