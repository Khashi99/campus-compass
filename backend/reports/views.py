from rest_framework import generics, permissions, serializers

from .models import StudentReport


class StudentReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudentReport
        fields = ["id", "incident", "report_type", "description", "submitted_at"]
        read_only_fields = ["id", "submitted_at"]


class SubmitReportView(generics.CreateAPIView):
    serializer_class = StudentReportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class MyReportsView(generics.ListAPIView):
    serializer_class = StudentReportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return StudentReport.objects.filter(user=self.request.user)
