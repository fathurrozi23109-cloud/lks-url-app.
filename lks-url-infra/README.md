# lks-url-infra

Terraform untuk URL Shortener (Arasaka Corp.) di AWS Academy (us-east-1).

## Sebelum push
1. Buat bucket S3 manual `lks-url-tfstate-<YourCity-YourName>` (versioning ON).
2. Ganti nilai `bucket` di `backend.tf` dengan nama bucket tersebut.
3. Tambah GitHub secrets: AWS_ACCOUNT_ID, AWS_REGION, AWS_ACCESS_KEY_ID,
   AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, DB_PASSWORD.
4. Push ke `main` -> workflow `deploy.yml` menjalankan terraform apply.

## Catatan
- Semua resource memakai prefix `lks-url-` dan tag `Project=lks-url`.
- IAM memakai `LabRole` (tidak membuat role baru).
- Jangan ubah `.github/workflows/classroom.yml`, `.github/classroom/`, `.github/scripts/` bila ada dari template.
