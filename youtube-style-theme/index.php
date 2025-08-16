<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php wp_title('|', true, 'right'); ?> <?php bloginfo('name'); ?></title>
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
    <header>
        <a href="<?php echo home_url(); ?>" class="logo">YouTube Style</a>
        
        <nav>
            <a href="#" class="active">首页</a>
            <a href="#">探索</a>
            <a href="#">Shorts</a>
            <a href="#">订阅</a>
        </nav>
        
        <div class="search-container">
            <input type="text" class="search-input" placeholder="搜索">
            <button class="search-button">搜索</button>
        </div>
        
        <div class="user-menu">
            <a href="#">创建</a>
            <a href="#">通知</a>
            <a href="#">登录</a>
        </div>
    </header>
    
    <div class="sidebar">
        <a href="#" class="sidebar-item active">
            <div class="sidebar-icon">🏠</div>
            <span>首页</span>
        </a>
        <a href="#" class="sidebar-item">
            <div class="sidebar-icon">🔥</div>
            <span>热门</span>
        </a>
        <a href="#" class="sidebar-item">
            <div class="sidebar-icon">📺</div>
            <span>订阅</span>
        </a>
        <a href="#" class="sidebar-item">
            <div class="sidebar-icon">📚</div>
            <span>学习</span>
        </a>
        <a href="#" class="sidebar-item">
            <div class="sidebar-icon">🎵</div>
            <span>音乐</span>
        </a>
        <a href="#" class="sidebar-item">
            <div class="sidebar-icon">🎮</div>
            <span>游戏</span>
        </a>
    </div>
    
    <main>
        <h1 class="page-title">推荐视频</h1>
        
        <div class="video-grid">
            <?php
            $args = array(
                'post_type' => 'post',
                'posts_per_page' => 12,
                'post_status' => 'publish'
            );
            
            $query = new WP_Query($args);
            
            if ($query->have_posts()) :
                while ($query->have_posts()) : $query->the_post();
                    ?>
                    <div class="video-card">
                        <div class="video-thumbnail">
                            <?php if (has_post_thumbnail()) : ?>
                                <?php the_post_thumbnail('medium'); ?>
                            <?php else : ?>
                                <div style="background-color: #000; width: 100%; height: 100%; display: flex; align-items: center; justify-content: center;">
                                    <span style="color: #fff;">视频缩略图</span>
                                </div>
                            <?php endif; ?>
                            <div class="video-duration">10:25</div>
                        </div>
                        <div class="video-info">
                            <div class="channel-avatar"></div>
                            <div class="video-details">
                                <h3 class="video-title"><?php the_title(); ?></h3>
                                <a href="#" class="channel-name">频道名称</a>
                                <p class="video-meta">100K 次观看 · 2天前</p>
                            </div>
                        </div>
                    </div>
                    <?php
                endwhile;
                wp_reset_postdata();
            else :
                echo '<p>暂无视频。</p>';
            endif;
            ?>
        </div>
    </main>
    
    <footer>
        <p>&copy; 2025 YouTube Style Theme. 所有权利 reserved.</p>
    </footer>
    
    <?php wp_footer(); ?>
</body>
</html>