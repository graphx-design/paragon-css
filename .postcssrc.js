module.exports = {
	map: {
		inline: false,
		sourcesContent: true,
	},
	plugins: [
		require('postcss-import')({
			path: ['./src/'],
		}),
		require('postcss-custom-properties')({
			preserve: false,
		}),
		require('cssnano')({
			preset: 'default',
		}),
		require('postcss-combine-media-query')({}),
	],
};
