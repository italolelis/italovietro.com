const contentful = require('contentful');
const manifestConfig = require('./manifest-config');
require('dotenv').config();

const { ACCESS_TOKEN, SPACE_ID, ANALYTICS_ID, DETERMINISTIC, GITHUB_TOKEN, DEVTO_USERNAME } = process.env;

const client = contentful.createClient({
  space: SPACE_ID,
  accessToken: ACCESS_TOKEN,
});

const getAboutEntry = entry => entry.sys.contentType.sys.id === 'about';

const plugins = [
  'gatsby-plugin-react-helmet',
  'gatsby-plugin-styled-components',
  'gatsby-transformer-remark',
  'gatsby-plugin-offline',
  {
    resolve: "gatsby-source-graphql",
    options: {
      typeName: "GitHub",
      fieldName: "github",
      url: "https://api.github.com/graphql",
      headers: {
        Authorization: `Bearer ${GITHUB_TOKEN}`,
      },
    },
  },
  {
    resolve: "gatsby-source-dev",
    options: {
      username: DEVTO_USERNAME
    }
  },
  {
    resolve: 'gatsby-plugin-web-font-loader',
    options: {
      google: {
        families: ['Cabin', 'Open Sans'],
      },
    },
  },
  {
    resolve: 'gatsby-plugin-manifest',
    options: manifestConfig,
  },
  {
    resolve: 'gatsby-source-contentful',
    options: {
      spaceId: SPACE_ID,
      accessToken: ACCESS_TOKEN,
    },
  },
];

module.exports = client.getEntries().then(entries => {
  if (ANALYTICS_ID) {
    plugins.push({
      resolve: 'gatsby-plugin-google-analytics',
      options: {
        trackingId: ANALYTICS_ID,
      },
    });
  }

  return {
    siteMetadata: {
      deterministicBehaviour: !!DETERMINISTIC,
    },
    plugins,
  };
});
