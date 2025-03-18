;; Improvement Tracking Contract
;; Manages progress on addressing accessibility deficiencies

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-IMPROVEMENT-EXISTS (err u101))
(define-constant ERR-IMPROVEMENT-NOT-FOUND (err u102))
(define-constant ERR-INVALID-STATUS (err u103))

;; Status constants
(define-constant STATUS-PLANNED u1)
(define-constant STATUS-IN-PROGRESS u2)
(define-constant STATUS-COMPLETED u3)
(define-constant STATUS-VERIFIED u4)

;; Data maps
(define-map improvements
  { improvement-id: uint }
  {
    facility-id: uint,
    finding-id: uint,
    description: (string-utf8 200),
    status: uint,
    created-at: uint,
    target-date: uint,
    completed-date: uint,
    assigned-to: principal
  }
)

(define-map improvement-updates
  { improvement-id: uint, update-id: uint }
  {
    date: uint,
    status: uint,
    notes: (string-utf8 200),
    updated-by: principal
  }
)

;; Variables
(define-data-var admin principal tx-sender)
(define-data-var next-improvement-id uint u1)
(define-data-var next-update-id uint u1)

;; Authorization check
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Improvement functions
(define-public (create-improvement-plan
  (facility-id uint)
  (finding-id uint)
  (description (string-utf8 200))
  (target-date uint)
  (assigned-to principal))
  (let
    (
      (improvement-id (var-get next-improvement-id))
    )
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)

    (map-set improvements
      { improvement-id: improvement-id }
      {
        facility-id: facility-id,
        finding-id: finding-id,
        description: description,
        status: STATUS-PLANNED,
        created-at: block-height,
        target-date: target-date,
        completed-date: u0,
        assigned-to: assigned-to
      }
    )

    (var-set next-improvement-id (+ improvement-id u1))
    (ok improvement-id)
  )
)

(define-public (update-improvement-status (improvement-id uint) (new-status uint) (notes (string-utf8 200)))
  (let
    (
      (improvement (map-get? improvements { improvement-id: improvement-id }))
      (update-id (var-get next-update-id))
    )
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (is-some improvement) ERR-IMPROVEMENT-NOT-FOUND)
    (asserts! (and (>= new-status u1) (<= new-status u4)) ERR-INVALID-STATUS)

    (map-set improvement-updates
      { improvement-id: improvement-id, update-id: update-id }
      {
        date: block-height,
        status: new-status,
        notes: notes,
        updated-by: tx-sender
      }
    )

    (map-set improvements
      { improvement-id: improvement-id }
      (merge (unwrap-panic improvement)
        {
          status: new-status,
          completed-date: (if (is-eq new-status STATUS-COMPLETED) block-height (get completed-date (unwrap-panic improvement)))
        }
      )
    )

    (var-set next-update-id (+ update-id u1))
    (ok true)
  )
)

(define-public (get-improvement (improvement-id uint))
  (ok (map-get? improvements { improvement-id: improvement-id }))
)

(define-public (get-improvement-update (improvement-id uint) (update-id uint))
  (ok (map-get? improvement-updates { improvement-id: improvement-id, update-id: update-id }))
)

;; Admin functions
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (var-set admin new-admin)
    (ok true)
  )
)

