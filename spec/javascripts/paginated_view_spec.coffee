# #= require views/paginated
#
# describe "Paginated View", ->
#   beforeEach ->
#     @collection = new Backbone.Collection()
#     @collection.pageInfo = ->
#       info =
#         current_user_id: 4
#         total: 50
#         page: 1
#         perPage: 5
#         prev: false
#         next: true
#         range: [1, 2, 3, 4, 5, 6, 7, 8, 9, '...', 49, 50]
#
#     @view = new Pixie.Views.Paginated
#       collection: @collection
#
#   describe "initialization", ->
#     it "should create a page link container", ->
#       expect(@view.el.get(0).nodeName).toEqual('NAV')
#       expect(@view.el).toHaveClass('pagination')
#
#     it "should have the correct number of page links", ->
#       # +3 because prev, next, and spinner elements
#       expect(@view.render().el.children().length).toEqual(@collection.pageInfo().range.length + 3)
