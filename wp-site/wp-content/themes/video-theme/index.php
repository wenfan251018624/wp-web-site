<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Video Site</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .video-container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .video-item {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        .video-title {
            font-size: 24px;
            margin-bottom: 10px;
            color: #333;
        }
        .video-embed {
            width: 100%;
            height: 0;
            padding-bottom: 56.25%; /* 16:9 Aspect Ratio */
            position: relative;
        }
        .video-embed iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: none;
        }
        .video-description {
            margin-top: 15px;
            color: #666;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="video-container">
        <h1>Video Site</h1>
        
        <div class="video-item">
            <div class="video-title">Sample Video 1</div>
            <div class="video-embed">
                <iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ" allowfullscreen></iframe>
            </div>
            <div class="video-description">
                This is a sample video description. You can embed videos from YouTube, Vimeo, and other platforms.
            </div>
        </div>
        
        <div class="video-item">
            <div class="video-title">Sample Video 2</div>
            <div class="video-embed">
                <iframe src="https://www.youtube.com/embed/ScMzIvxBSi4" allowfullscreen></iframe>
            </div>
            <div class="video-description">
                Another sample video with embedding capability.
            </div>
        </div>
    </div>
</body>
</html>