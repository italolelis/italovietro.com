import React from 'react';
import { Heading, Text, Flex, Box } from 'rebass';
import { StaticQuery, graphql } from 'gatsby';
import styled from 'styled-components';
import Fade from 'react-reveal/Fade';
import Section from '../components/Section';
import { CardContainer, Card } from '../components/Card';
import Triangle from '../components/Triangle';
import ImageSubtitle from '../components/ImageSubtitle';

const Background = () => (
  <div>
    <Triangle
      color="backgroundDark"
      height={['15vh', '10vh']}
      width={['100vw', '100vw']}
      invertX
    />

    <Triangle
      color="secondary"
      height={['50vh', '40vh']}
      width={['70vw', '40vw']}
      invertY
    />

    <Triangle
      color="primaryDark"
      height={['40vh', '15vh']}
      width={['100vw', '100vw']}
      invertX
      invertY
    />
  </div>
);

const CoverImage = styled.img`
  width: 100%;
  object-fit: cover;
`;

const EllipsisHeading = styled(Heading)`
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-inline-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  border-bottom: ${props => props.theme.colors.primary} 5px solid;
`;

const Post = ({ title, social_image, url, published_at }) => (
  <Card onClick={() => window.open(url, '_blank')} pb={4}>
    <EllipsisHeading m={3} p={1}>
      {title}
    </EllipsisHeading>
    {social_image && <CoverImage src={social_image} height="200px" alt={title} />}
    <ImageSubtitle bg="primary" color="white" x="right" y="bottom" round>
      {`${new Date(published_at).toDateString()}`}
    </ImageSubtitle>
  </Card>
);

const Writing = () => (
  <StaticQuery
    query={graphql`
      query DevToPostQuery {
        allDevArticles {
          edges {
            node {
              article {
                id
                title
                description
                published_at
                url
                social_image
              }
            }
          }
        }
      }
    `}
    render={({ allDevArticles }) => {
      return (
        <Section.Container id="writing" Background={Background}>
          <Section.Header name="Writing" icon="✍️" label="writing" />
          <CardContainer minWidth="300px">
            {allDevArticles.edges.map(({ node, key }) => (
              <Fade bottom key={key}>
                <Post {...node.article} />
              </Fade>
            ))}
          </CardContainer>
        </Section.Container>
      );
    }}
  />
);

export default Writing;
