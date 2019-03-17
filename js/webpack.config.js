
var path = require('path')

module.exports = {
    entry: { MercuryWrapper: "./mercury_wrapper.js" },
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: "[name].bundle.js",
        library: "[name]",
        libraryTarget: "var"
    }
};
