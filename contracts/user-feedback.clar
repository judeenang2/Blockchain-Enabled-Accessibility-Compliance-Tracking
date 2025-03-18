;; User Feedback Contract
;; Collects input from people with disabilities

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-FACILITY-NOT-FOUND (err u101))
(define-constant ERR-FEEDBACK-EXISTS (err u102))
(define-constant ERR-FEEDBACK-NOT-FOUND (err u103))
(define-constant ERR-INVALID-RATING (err u104))
(define-constant ERR-INVALID-CATEGORY (err u105))

;; Feedback category constants
(define-constant CATEGORY-PHYSICAL-ACCESS u1)
(define-constant CATEGORY-VISUAL-ACCOMMODATIONS u2)
(define-constant CATEGORY-AUDITORY-ACCOMMODATIONS u3)
(define-constant CATEGORY-COGNITIVE-ACCOMMODATIONS u4)
(define-constant CATEGORY-DIGITAL-ACCESSIBILITY u5)
(define-constant CATEGORY-STAFF-ASSISTANCE u6)

;; Data maps
(define-map feedback
  { feedback-id: uint }
  {
    facility-id: uint,
    user: principal,
    date: uint,
    category: uint,
    rating: uint,
    comments: (string-utf8 500)
  }
)

(define-map facility-ratings
  { facility-id: uint, category: uint }
  {
    total-ratings: uint,
    sum-ratings: uint,
    last-updated: uint
  }
)

;; Variables
(define-data-var admin principal tx-sender)
(define-data-var next-feedback-id uint u1)

;; Authorization check
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Feedback functions
(define-public (submit-feedback
  (facility-id uint)
  (category uint)
  (rating uint)
  (comments (string-utf8 500)))
  (let
    (
      (feedback-id (var-get next-feedback-id))
      (current-ratings (default-to
        { total-ratings: u0, sum-ratings: u0, last-updated: u0 }
        (map-get? facility-ratings { facility-id: facility-id, category: category })))
    )
    (asserts! (and (>= category u1) (<= category u6)) ERR-INVALID-CATEGORY)
    (asserts! (and (>= rating u1) (<= rating u5)) ERR-INVALID-RATING)

    ;; Store the feedback
    (map-set feedback
      { feedback-id: feedback-id }
      {
        facility-id: facility-id,
        user: tx-sender,
        date: block-height,
        category: category,
        rating: rating,
        comments: comments
      }
    )

    ;; Update the ratings
    (map-set facility-ratings
      { facility-id: facility-id, category: category }
      {
        total-ratings: (+ (get total-ratings current-ratings) u1),
        sum-ratings: (+ (get sum-ratings current-ratings) rating),
        last-updated: block-height
      }
    )

    (var-set next-feedback-id (+ feedback-id u1))
    (ok feedback-id)
  )
)

(define-public (get-feedback (feedback-id uint))
  (ok (map-get? feedback { feedback-id: feedback-id }))
)

(define-public (get-category-rating (facility-id uint) (category uint))
  (let
    (
      (ratings (map-get? facility-ratings { facility-id: facility-id, category: category }))
    )
    (asserts! (and (>= category u1) (<= category u6)) ERR-INVALID-CATEGORY)

    (ok (default-to
      { total-ratings: u0, sum-ratings: u0, last-updated: u0 }
      ratings))
  )
)

(define-read-only (calculate-average-rating (facility-id uint) (category uint))
  (let
    (
      (ratings (default-to
        { total-ratings: u0, sum-ratings: u0, last-updated: u0 }
        (map-get? facility-ratings { facility-id: facility-id, category: category })))
      (total (get total-ratings ratings))
      (sum (get sum-ratings ratings))
    )
    (if (> total u0)
      (/ sum total)
      u0
    )
  )
)

;; Admin functions
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (var-set admin new-admin)
    (ok true)
  )
)

