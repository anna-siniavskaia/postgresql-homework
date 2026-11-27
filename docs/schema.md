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

This physical PostgreSQL model is created by [`sql/01_restaurant_schema.sql`](../sql/01_restaurant_schema.sql). Primary and foreign keys maintain referential integrity. `CHECK` constraints and a validation trigger enforce business rules. A GiST exclusion constraint prevents overlapping active reservations for the same table.
