var webpack = require('webpack');
var entries = [];
var loaders = [];
if (process.env.DEV) {
    entries = [ 'webpack-dev-server/client?http://localhost:8888', 'webpack/hot/dev-server' ];
    loaders = [ { test: /view\.ls$/, loader: 'react-hot' } ];
}

module.exports = {
    entry: entries.concat([
        './main.ls',
        './js/jquery-ui-1.10.4.custom.min.js',
        './js/jquery.hoverIntent.js',
        './js/bootstrap/dropdown.js',
        './js/simp-trad.js',
        './js/phantomjs-shims.js',
        './js/console-polyfill.js',
        './js/es5-shim.js',
        './js/es5-sham.js'
    ]),
    output: {
        path: __dirname + '/js/',
        filename: 'deps.js',
        publicPath: '/js/'
    },
    plugins: [
        new webpack.HotModuleReplacementPlugin()
    ],
    module: {
        loaders: loaders.concat([
            //{ test: /\.css$/, loader: 'style!css' },
            //{ test: /\.scss$/, loader: 'style!css!sass?includePaths[]=' + require('path').resolve(__dirname, './sass') },
            //{ test: /\.sass$/, loader: 'style!css!sass?indentedSyntax=sass&includePaths[]=' + require('path').resolve(__dirname, './sass') },
            // { test: /\.(png|jpg|ttf|eot|woff|svg|otf)$/, loader: 'file' }
            { test: /\.ls$/, loader: 'livescript' },
        ])
    },
}
