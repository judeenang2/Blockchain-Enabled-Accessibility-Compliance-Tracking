;; Certification Contract
;; Issues verifiable accessibility compliance credentials

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-FACILITY-NOT-FOUND (err u101))
(define-constant ERR-CERTIFICATION-EXISTS (err u102))
(define-constant ERR-CERTIFICATION-NOT-FOUND (err u103))
(define-constant ERR-CERTIFICATION-EXPIRED (err u104))
(define-constant ERR-INVALID-LEVEL (err u105))

;; Certification level constants
(define-constant LEVEL-BASIC u1)
(define-constant LEVEL-STANDARD u2)
(define-constant LEVEL-ADVANCED u3)

;; Data maps
(define-map certifications
  { facility-id: uint }
  {
    certification-id: uint,
    issue-date: uint,
    expiration-date: uint,
    level: uint,
    certifier: principal,
    is-active: bool
  }
)

(define-map certification-history
  { certification-id: uint }
  {
    facility-id: uint,
    issue-date: uint,
    expiration-date: uint,
    level: uint,
    certifier: principal,
    revocation-date: uint,
    revocation-reason: (string-utf8 200)
  }
)

;; Variables
(define-data-var admin principal tx-sender)
(define-data-var next-certification-id uint u1)

;; Authorization check
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Certification functions
(define-public (issue-certification (facility-id uint) (level uint) (validity-period uint))
  (let
    (
      (certification-id (var-get next-certification-id))
      (expiration-date (+ block-height validity-period))
    )
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= level u1) (<= level u3)) ERR-INVALID-LEVEL)

    ;; If there's an existing certification, move it to history
    (match (map-get? certifications { facility-id: facility-id })
      prev-cert (begin
        (map-set certification-history
          { certification-id: (get certification-id prev-cert) }
          {
            facility-id: facility-id,
            issue-date: (get issue-date prev-cert),
            expiration-date: (get expiration-date prev-cert),
            level: (get level prev-cert),
            certifier: (get certifier prev-cert),
            revocation-date: block-height,
            revocation-reason: u"Superseded by new certification"
          }
        )
        true
      )
      false
    )

    (map-set certifications
      { facility-id: facility-id }
      {
        certification-id: certification-id,
        issue-date: block-height,
        expiration-date: expiration-date,
        level: level,
        certifier: tx-sender,
        is-active: true
      }
    )

    (var-set next-certification-id (+ certification-id u1))
    (ok certification-id)
  )
)

(define-public (verify-certification (facility-id uint))
  (let
    (
      (cert (map-get? certifications { facility-id: facility-id }))
    )
    (asserts! (is-some cert) ERR-CERTIFICATION-NOT-FOUND)
    (asserts! (get is-active (unwrap-panic cert)) ERR-CERTIFICATION-NOT-FOUND)
    (asserts! (<= block-height (get expiration-date (unwrap-panic cert))) ERR-CERTIFICATION-EXPIRED)

    (ok (unwrap-panic cert))
  )
)

(define-public (revoke-certification (facility-id uint) (reason (string-utf8 200)))
  (let
    (
      (cert (map-get? certifications { facility-id: facility-id }))
    )
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (is-some cert) ERR-CERTIFICATION-NOT-FOUND)

    ;; Move to history
    (map-set certification-history
      { certification-id: (get certification-id (unwrap-panic cert)) }
      {
        facility-id: facility-id,
        issue-date: (get issue-date (unwrap-panic cert)),
        expiration-date: (get expiration-date (unwrap-panic cert)),
        level: (get level (unwrap-panic cert)),
        certifier: (get certifier (unwrap-panic cert)),
        revocation-date: block-height,
        revocation-reason: reason
      }
    )

    ;; Update active certification
    (map-set certifications
      { facility-id: facility-id }
      (merge (unwrap-panic cert)
        { is-active: false }
      )
    )

    (ok true)
  )
)

(define-public (get-certification (facility-id uint))
  (ok (map-get? certifications { facility-id: facility-id }))
)

(define-public (get-certification-history (certification-id uint))
  (ok (map-get? certification-history { certification-id: certification-id }))
)

;; Admin functions
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (var-set admin new-admin)
    (ok true)
  )
)

