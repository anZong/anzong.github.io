---
title: Django REST FrameWork
categories: 
    - 后端开发
date: 2017-12-16 17:28
---

### 配置要求
REST framework有以下要求：
- Python(2.7,3.2,3.3,3.4,3.5)
- Django(1.7+,1.8,1.9)

可选的包：
- Markdown(2.1.0+) -为可视化API提供支持
- django-filter(0.9.2+)-过滤支持

### 安装
```python
pip install djangorestframework
pip install markdown
pip install django-filter
```
或者
```
git clone git@github.com:tomchristie/django-rest-framework.git
```

### 注册APP
```
INSTALLED_APPS=(
    ...,
    'snippets',
    'rest_framework'
)

```

### 可视化API
添加REST framework的登录/登出视图。在根urls.py文件中添加：
```
urlpatterns = [
    ...,
    url(r'/api-auth',include('rest_framework.urls',namespace='rest_framework')
]
```

setting.py模块中：
```
REST_FRAMEWORK = {
    # 使用Django的标准`django.contrib.auth`权限管理类,
    # 或者为尚未认证的用户，赋予只读权限.
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.DjangoModelPermissionsOrAnonReadOnly'
    ]
}
```
<!-- more -->
### 开始REST

#### 新建模型 
snippets/models.py
```python
from django.db import models
from pygments.lexers import get_all_lexers
from pygments.styles import get_all_styles

LEXERS = [item for item in get_all_lexers() if item[1]]
LANGUAGE_CHOICE = sorted([(item[1][0], item[0]) for item in LEXERS])
STYLE_CHOICE = sorted([(item, item) for item in get_all_styles()])


class Snippet(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    owner = models.ForeignKey(to='auth.User', related_name='snippets')
    title = models.CharField(max_length=100, blank=True, default='')
    code = models.TextField()
    highlighted = models.TextField()
    linenos = models.BooleanField(default=False)
    language = models.CharField(choices=LANGUAGE_CHOICE, default='python', max_length=100)
    style = models.CharField(choices=STYLE_CHOICE, default='friendly', max_length=100)

    def save(self, *args, **kwargs):
        """
        使用pygments来创建高亮代码
        """
        from pygments.lexers import get_lexer_by_name
        from pygments.formatters.html import HtmlFormatter
        from pygments import highlight
        lexer = get_lexer_by_name(self.language)
        linenos = self.linenos and 'table' or False
        options = self.title and {'title': self.title} or {}
        formatter = HtmlFormatter(style=self.style, linenos=linenos, full=True, **options)
        self.highlighted = highlight(self.code, lexer, formatter)
        super(Snippet, self).save(*args, **kwargs)

    class Meta:
        ordering = ('created',)
```

#### 序列化
snippets/serializers.py
```python
from rest_framework import serializers
from models import LANGUAGE_CHOICE, STYLE_CHOICE, Snippet

class SnippetModelSerializer(serializers.HyperlinkedModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    highlight = serializers.HyperlinkedIdentityField(view_name='snippet-highlight', format='html')

    class Meta:
        model = Snippet
        fields = ('url', 'owner', 'highlight', 'title', 'code', 'linenos', 'language', 'style')

```

#### 认证和权限
snippets/permissions.py
```python
# coding:UTF-8
from rest_framework import permissions


class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    自定义权限，只有创建者才能编辑，其他用户只能查看
    """

    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True

        return obj.owner == request.user

```

#### 视图
snippets/views.py
```python
from models import Snippet
from rest_framework.decorators import detail_route
from rest_framework import permissions, viewsets
from rest_framework.response import Response
from serializers import SnippetModelSerializer


class SnippetViewSet(viewsets.ModelViewSet):
    """
    提供list,create,retrieve,update,destory
    额外添加highlight
    """
    from snippets.permissions import IsOwnerOrReadOnly
    queryset = Snippet.objects.all()
    serializer_class = SnippetModelSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    @detail_route(renderer_classes=[renderers.StaticHTMLRenderer])
    def highlight(self, request, *args, **kwargs):
        snippet = self.get_object()
        return Response(snippet.highlighted)
```


#### 路由
urls.py模块中
```python
from snippets import views
from rest_framework import routers
from django.conf.urls import url, include
from django.contrib import admin

router = routers.DefaultRouter()
router.register(r'userlist',views.UserViewSet)
router.register(r'snippets',views.SnippetViewSet)

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^api/', include(router.urls)),
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework'))
]
```
