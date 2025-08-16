#!/usr/bin/env php
<?php
/**
 * 自动创建YouTube视频帖子的脚本
 */

// WordPress配置
define('WP_USE_THEMES', false);
require_once('wp-site/wp-load.php');

// YouTube视频信息
$youtube_videos = [
    [
        'title' => '如何使用WordPress创建视频网站',
        'description' => '本视频将教你如何使用WordPress创建一个专业的视频网站，包含所有必要的设置和插件推荐。',
        'video_id' => 'gJVdNHSH7hE',
        'category' => '教程'
    ],
    [
        'title' => 'WordPress性能优化完全指南',
        'description' => '学习如何优化你的WordPress网站性能，提高加载速度和用户体验。',
        'video_id' => 'DK5mmgmkqJE',
        'category' => '优化'
    ],
    [
        'title' => 'WordPress安全性最佳实践',
        'description' => '保护你的WordPress网站免受黑客攻击的安全性最佳实践和技巧。',
        'video_id' => 'HR0CdYoKtDc',
        'category' => '安全'
    ]
];

// 创建分类
function create_category_if_not_exists($category_name) {
    $category = get_category_by_slug(sanitize_title($category_name));
    if (!$category) {
        $cat_id = wp_create_category($category_name);
        return $cat_id;
    }
    return $category->term_id;
}

// 创建YouTube视频帖子
function create_youtube_post($video_data) {
    // 创建分类
    $category_id = create_category_if_not_exists($video_data['category']);
    
    // 创建帖子内容，包含YouTube嵌入代码
    $post_content = '<!-- wp:embed {"url":"https://www.youtube.com/watch?v=' . $video_data['video_id'] . '","type":"video","providerNameSlug":"youtube","responsive":true,"className":"wp-embed-aspect-16-9 wp-has-aspect-ratio"} -->';
    $post_content .= '<figure class="wp-block-embed is-type-video is-provider-youtube wp-block-embed-youtube wp-embed-aspect-16-9 wp-has-aspect-ratio">';
    $post_content .= '<div class="wp-block-embed__wrapper">';
    $post_content .= 'https://www.youtube.com/watch?v=' . $video_data['video_id'];
    $post_content .= '</div></figure><!-- /wp:embed -->';
    $post_content .= '<p>' . $video_data['description'] . '</p>';
    
    // 帖子数据
    $post_data = array(
        'post_title'    => $video_data['title'],
        'post_content'  => $post_content,
        'post_status'   => 'publish',
        'post_author'   => 1,
        'post_category' => array($category_id)
    );
    
    // 插入帖子
    $post_id = wp_insert_post($post_data);
    
    if ($post_id) {
        echo "成功创建帖子: " . $video_data['title'] . " (ID: " . $post_id . ")\n";
        return $post_id;
    } else {
        echo "创建帖子失败: " . $video_data['title'] . "\n";
        return false;
    }
}

// 创建自定义页面模板用于主页
function create_homepage_template() {
    $template_content = '<?php
/*
Template Name: YouTube主页模板
*/
get_header(); ?>

<div id="primary" class="content-area">
    <main id="main" class="site-main">
        <h1>视频库</h1>
        
        <div class="video-grid">
            <?php
            $args = array(
                \'post_type\' => \'post\',
                \'posts_per_page\' => 12,
                \'post_status\' => \'publish\'
            );
            
            $query = new WP_Query($args);
            
            if ($query->have_posts()) :
                while ($query->have_posts()) : $query->the_post();
                    ?>
                    <div class="video-card">
                        <a href="<?php the_permalink(); ?>">
                            <?php if (has_post_thumbnail()) : ?>
                                <?php the_post_thumbnail(\'medium\'); ?>
                            <?php else : ?>
                                <div class="video-placeholder">
                                    <p>视频缩略图</p>
                                </div>
                            <?php endif; ?>
                            <h3><?php the_title(); ?></h3>
                            <p class="video-meta">
                                <?php the_date(); ?> · 
                                <?php 
                                $categories = get_the_category();
                                if (!empty($categories)) {
                                    echo $categories[0]->name;
                                }
                                ?>
                            </p>
                        </a>
                    </div>
                    <?php
                endwhile;
                wp_reset_postdata();
            else :
                echo \'<p>暂无视频。</p>\';
            endif;
            ?>
        </div>
    </main>
</div>

<style>
.video-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
    padding: 20px 0;
}

.video-card {
    border: 1px solid #ddd;
    border-radius: 8px;
    overflow: hidden;
    transition: transform 0.2s, box-shadow 0.2s;
}

.video-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}

.video-card a {
    text-decoration: none;
    color: inherit;
}

.video-card img {
    width: 100%;
    height: auto;
    display: block;
}

.video-placeholder {
    background-color: #f0f0f0;
    height: 169px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.video-card h3 {
    padding: 10px;
    margin: 0;
    font-size: 16px;
    font-weight: 500;
}

.video-meta {
    padding: 0 10px 10px;
    margin: 0;
    font-size: 13px;
    color: #666;
}
</style>

<?php get_footer(); ?>';
    
    // 将模板保存到主题目录
    $template_path = 'wp-site/wp-content/themes/' . get_template() . '/youtube-homepage.php';
    file_put_contents($template_path, $template_content);
    
    echo "主页模板已创建: " . $template_path . "\n";
}

// 主执行流程
echo "开始创建YouTube视频帖子...\n";

// 创建YouTube视频帖子
foreach ($youtube_videos as $video) {
    create_youtube_post($video);
}

// 创建主页模板
create_homepage_template();

echo "完成！YouTube视频帖子和主页模板已创建。\n";
echo "请登录WordPress后台设置主页使用'YouTube主页模板'。\n";
?>