module.exports = {
	syntax: 'postcss-scss',
	map: {
		inline: false,
		sourcesContent: true,
	},
	plugins: [
		require('postcss-import')({
			path: ['./src/'],
		}),
		require('postcss-advanced-variables')({}),
		require('cssnano')({
			preset: 'default',
		}),
		require('postcss-combine-media-query')({}),
	],
};
