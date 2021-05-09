<div class="categories">
  <div class="title">分类</div>
  <div class="category-all">
    {{ list_categories() }}
  </div>
</div>
<div class="tags">
  <div class="title">标签</div>
  <div class="tag-cloud-tags">
    {{ tagcloud({min_font: 12, max_font: 30, amount: 300, color: true, start_color: '#ccc', end_color: '#ff4d4f'}) }}
  </div>
</div>
