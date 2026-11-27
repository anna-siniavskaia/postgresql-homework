# Restaurant schema

```mermaid
erDiagram
    RESTAURANTS ||--o{ OPENING_HOURS : has
    RESTAURANTS ||--o{ SCHEDULE_EXCEPTIONS : overrides
    RESTAURANTS ||--o{ DINING_HALLS : contains
    DINING_HALLS ||--o{ DINING_TABLES : contains
    RESTAURANTS ||--o{ EMPLOYEES : employs
    RESTAURANTS ||--o{ RESERVATIONS : receives
    DINING_TABLES ||--o{ RESERVATIONS : assigned_to
    GUESTS ||--o{ RESERVATIONS : makes
    EMPLOYEES o|--o{ RESERVATIONS : creates
    RESERVATIONS ||--o{ RESERVATION_STATUS_HISTORY : records
    RESERVATIONS ||--o{ PAYMENTS : has
```

Это физическая модель PostgreSQL, создаваемая файлом [`sql/01_restaurant_schema.sql`](../sql/01_restaurant_schema.sql). Первичные и внешние ключи поддерживают ссылочную целостность. `CHECK`-ограничения и триггер проверяют бизнес-правила, а GiST exclusion constraint не позволяет сохранить пересекающиеся активные бронирования одного стола.
