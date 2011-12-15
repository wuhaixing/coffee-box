Post     = require('../models/post').Post
postPath = require('../helpers/posts_helper').postPath
markdown = require('../../lib/markdown').Markdown

POSTS_PER_PAGE = 5

PostsController =
  # GET /posts
  index: (req, res, next) ->
    # check pagination param: /posts/?page=2
    pageNo = parseInt(req.query['page'], 10) or 1
    Post.count { public: true }, (err, totalPosts) ->
      totalPages = Math.ceil(totalPosts / POSTS_PER_PAGE)
      options =
        skip:   (pageNo - 1) * POSTS_PER_PAGE
        limit:  POSTS_PER_PAGE
        sort:   [['createdAt', 'desc']]
      Post.find { public: true }, {}, options, (err, posts) ->
        res.render 'posts/index'
          posts:      posts
          pageNo:     pageNo
          totalPages: totalPages


  # GET /year/month/day/:slug.:format?
  show: (req, res, next) ->
    Post.findOne slug: req.params.slug, (err, post) ->
      if post
        res.render 'posts/show'
          post: post
      else
        res.redirect '404'

  # GET /posts/new
  new: (req, res, next) ->
    res.render 'posts/new'
      post: new Post

  # GET /year/month/day/:slug/edit
  edit: (req, res, next) ->
    Post.findOne slug: req.params.slug, (err, post) ->
      if post
        res.render 'posts/edit'
          post: post
      else
        res.redirect '404'

  # POST /posts
  create: (req, res, next) ->
    post = new Post(req.body.post or {})
    post.content = markdown(post.raw_content or '')
    post.save (err) ->
      if err
        req.flash 'error', err
        res.redirect 'back'
      else
        req.flash 'info', 'successfully posted'
        res.redirect postPath(post)

  # PUT /year/month/day/:slug
  update: (req, res, next) ->
    query = slug: req.params.slug
    console.log req.body.post
    Post.findOne query, (err, post) ->
      if post
        newPost = req.body.post or {}
        newPost.content = markdown(newPost.raw_content or '')
        newPost.createdAt = post.createdAt
        newPost.updatedAt = Date.now()
        Post.update query, newPost, (err) ->
          if err
            req.flash 'error', err
            res.redirect 'back'
          else
            req.flash 'info', 'successfully updated'
            res.redirect postPath(newPost)
      else
        res.redirect '404'

  # DELETE /year/month/day/:slug
  destroy: (req, res, next) ->
    Post.remove slug: req.params.slug

module.exports = PostsController
