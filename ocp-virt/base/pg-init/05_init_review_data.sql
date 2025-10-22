\c review_db

CREATE TABLE reviews (
    review_id UUID PRIMARY KEY,
    book_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating INT NOT NULL,
    review_text VARCHAR(200),
    publication_date TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

CREATE INDEX idx_reviews_book_id ON reviews(book_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);