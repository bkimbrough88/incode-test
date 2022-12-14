import * as React from 'react';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';

interface PostProperties {
    post: {
        id: string;
        author: string;
        datePosted: string;
        message: string;
    }
}

export default function (props: PostProperties) {
    const { post } = props

    return (
        <Grid item>
            <Card sx={{ display: 'flex' }}>
                <CardContent sx={{ flex: 1 }}>
                    <Typography component="h2" variant="h5">
                        {post.author}
                    </Typography>
                    <Typography variant="subtitle1" color="text.secondary">
                        {post.datePosted}
                    </Typography>
                    <Typography variant="subtitle1" paragraph>
                        {post.message}
                    </Typography>
                </CardContent>
            </Card>
        </Grid>
    );
}