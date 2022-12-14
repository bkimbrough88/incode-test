import * as React from 'react';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Link from '@mui/material/Link';
import {Grid} from "@mui/material";
import Post from "./Post";

function Copyright() {
  return (
      <Typography variant="body2" color="text.secondary" align="center">
        {'Copyright © '}
        <Link color="inherit" href="https://mui.com/">
          Brandon Kimbrough
        </Link>{' '}
        {new Date().getFullYear()}.
      </Typography>
  );
}

const posts = [
    {
        id: "abc",
        datePosted: "2022-12-13:15:20:36Z",
        author: "Bob",
        message: "Hello World"
    }
]

export default function App() {
  return (
      <Container maxWidth="sm">
        <Grid container spacing={4}>
            {posts.map((post) => (
                <Post key={post.id} post={post}/>
            ))}
        </Grid>
      </Container>
  );
}