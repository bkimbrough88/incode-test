import * as React from 'react';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';

export interface PostAttributes {
    id: string;
    author: string;
    datePosted: string;
    message: string;
}

interface PostProperties {
    post : PostAttributes
}

class Post extends React.Component<PostProperties, any> {
    render() {
        return (
            <Grid item>
                <Card sx={{ display: 'flex' }}>
                    <CardContent sx={{ flex: 1 }}>
                        <Typography component="h2" variant="h5">
                            {this.props.post.author}
                        </Typography>
                        <Typography variant="subtitle1" color="text.secondary">
                            {this.props.post.datePosted}
                        </Typography>
                        <Typography variant="subtitle1" paragraph>
                            {this.props.post.message}
                        </Typography>
                    </CardContent>
                </Card>
            </Grid>
        );
    }
}

export default Post;