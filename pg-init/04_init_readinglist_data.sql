\c readinglist_db

CREATE TABLE reading_lists (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    name VARCHAR(30) NOT NULL,
    description VARCHAR(200),
    creation_date TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

---

CREATE TABLE reading_list_items (
    reading_list_id UUID NOT NULL,
    book_id UUID NOT NULL,

    CONSTRAINT fk_reading_list
        FOREIGN KEY(reading_list_id) REFERENCES reading_lists(id)
        ON DELETE CASCADE,

    PRIMARY KEY (reading_list_id, book_id)
);