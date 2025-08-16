<?php
// 启用特色图像功能
add_theme_support('post-thumbnails');

// 注册菜单
register_nav_menus(array(
    'primary' => 'Primary Menu',
));

// 添加视频嵌入支持
function add_video_embed_support() {
    // 添加对视频文章格式的支持
    add_theme_support('post-formats', array('video'));
    
    // 添加自定义文章类型用于视频
    register_post_type('video', array(
        'labels' => array(
            'name' => 'Videos',
            'singular_name' => 'Video',
        ),
        'public' => true,
        'has_archive' => true,
        'supports' => array('title', 'editor', 'thumbnail', 'excerpt'),
        'menu_icon' => 'dashicons-video-alt3',
    ));
}
add_action('init', 'add_video_embed_support');

// 允许更多HTML标签在文章中使用（用于嵌入视频）
function allow_video_embed_tags($tags) {
    $tags['iframe'] = array(
        'src' => true,
        'width' => true,
        'height' => true,
        'frameborder' => true,
        'allowfullscreen' => true,
    );
    $tags['video'] = array(
        'src' => true,
        'width' => true,
        'height' => true,
        'controls' => true,
        'autoplay' => true,
        'loop' => true,
        'muted' => true,
    );
    return $tags;
}
add_filter('wp_kses_allowed_html', 'allow_video_embed_tags');

// 自动嵌入URL转换为视频播放器
function auto_embed_videos($content) {
    global $wp_embed;
    return $wp_embed->autoembed($content);
}
add_filter('the_content', 'auto_embed_videos');
?>