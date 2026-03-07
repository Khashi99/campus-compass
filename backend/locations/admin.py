from django.contrib import admin

from .models import Building, HazardZone, RouteEdge, RouteNode, SafetyResource, SafeZone

admin.site.register(Building)
admin.site.register(SafeZone)
admin.site.register(HazardZone)
admin.site.register(RouteNode)
admin.site.register(RouteEdge)
admin.site.register(SafetyResource)
