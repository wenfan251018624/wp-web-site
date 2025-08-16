<?php
/*
Theme Name: YouTube Style Theme
Description: A theme designed to look like YouTube for video content
Version: 1.0
Author: Claude Code
*/

// 移除不必要的头部信息
remove_action('wp_head', 'wp_generator');
remove_action('wp_head', 'wlwmanifest_link');
remove_action('wp_head', 'rsd_link');

// 添加主题支持
function youtube_theme_setup() {
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('html5', array('search-form', 'comment-form', 'comment-list', 'gallery', 'caption'));
}
add_action('after_setup_theme', 'youtube_theme_setup');

// 加载主题样式
function youtube_theme_styles() {
    wp_enqueue_style('youtube-theme-style', get_stylesheet_uri());
}
add_action('wp_enqueue_scripts', 'youtube_theme_styles');

// 自定义主页模板
function youtube_home_template($template) {
    if (is_front_page()) {
        return get_template_directory() . '/home.php';
    }
    return $template;
}
// add_filter('template_include', 'youtube_home_template');

// 注册导航菜单
function youtube_register_menus() {
    register_nav_menus(array(
        'header-menu' => '顶部菜单',
        'footer-menu' => '底部菜单'
    ));
}
add_action('init', 'youtube_register_menus');