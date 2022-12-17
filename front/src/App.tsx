import * as React from 'react';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Link from '@mui/material/Link';
import {Button, Grid, TextField} from '@mui/material';
import Post, {PostAttributes} from './Post';
import {v4 as uuidv4} from 'uuid';

function Copyright() {
    return (
        <Typography variant='body2' color='text.secondary' align='center'>
            {'Copyright © '}
            <Link color='inherit' href='https://mui.com/'>
                Brandon Kimbrough
            </Link>{' '}
            {new Date().getFullYear()}.
        </Typography>
    );
}

interface appState {
    dataIsLoaded: boolean;
    posts: PostAttributes[];
    author: string;
    message: string;
}

class App extends React.Component<any, appState> {
    constructor(props: any) {
        super(props);

        this.state = {
            dataIsLoaded: false,
            posts: [],
            author: '',
            message: ''
        }
    }

    componentDidMount() {
        fetch(`/api/posts`)
            .then((res) => res.json())
            .then((json) => {
                this.setState({
                    dataIsLoaded: true,
                    posts: json
                })
            })
    }

    handleAuthorChange(e: React.ChangeEvent<HTMLTextAreaElement>) {
        this.setState({author: e.target.value})
    }

    handleMessageChange(e: React.ChangeEvent<HTMLTextAreaElement>) {
        this.setState({message: e.target.value})
    }

    handleSubmitButton() {
        const post: PostAttributes = {
            id: uuidv4(),
            datePosted: Date.now().toString(),
            author: this.state.author,
            message: this.state.message
        }
        fetch('/api/posts', {
            method: 'POST',
            body: JSON.stringify(post),
            headers: {
                'Content-Type': 'application/json'
            }
        }).then((res) => {
            if (!res.ok) {
                console.log(`Failed to add message: ${res.statusText}`)
            }
        })
    }

    render() {
        const { dataIsLoaded, posts } = this.state;
        if (!dataIsLoaded)
            return <Typography component='h1'>Loading....</Typography>

        return (
            <Container maxWidth='sm'>
                <TextField id='author' label='author' onChange={this.handleAuthorChange} variant='outlined' />
                <TextField id='message' label='message' onChange={this.handleMessageChange} variant='outlined' />
                <Button id='submit' title='Add Comment' onSubmit={this.handleSubmitButton} variant='contained' />
                <Grid container spacing={4}>
                    {posts.map((post) => (
                        <Post key={post.id} post={post}/>
                    ))}
                </Grid>
                <Copyright/>
            </Container>
        );
    }
}

export default App;