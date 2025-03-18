;; Facility Assessment Contract
;; Records compliance with accessibility standards

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-FACILITY-EXISTS (err u101))
(define-constant ERR-FACILITY-NOT-FOUND (err u102))
(define-constant ERR-ASSESSMENT-EXISTS (err u103))
(define-constant ERR-ASSESSMENT-NOT-FOUND (err u104))

;; Compliance level constants
(define-constant COMPLIANCE-NON-COMPLIANT u1)
(define-constant COMPLIANCE-PARTIALLY-COMPLIANT u2)
(define-constant COMPLIANCE-FULLY-COMPLIANT u3)

;; Data maps
(define-map facilities
  { facility-id: uint }
  {
    name: (string-utf8 50),
    location: (string-utf8 100),
    facility-type: uint,
    registration-date: uint
  }
)

(define-map assessments
  { facility-id: uint, assessment-id: uint }
  {
    date: uint,
    assessor: principal,
    compliance-level: uint,
    findings-count: uint
  }
)

(define-map findings
  { assessment-id: uint, finding-id: uint }
  {
    category: uint,
    description: (string-utf8 200),
    severity: uint
  }
)

;; Variables
(define-data-var admin principal tx-sender)
(define-data-var next-facility-id uint u1)
(define-data-var next-assessment-id uint u1)

;; Authorization check
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Facility functions
(define-public (register-facility (name (string-utf8 50)) (location (string-utf8 100)) (facility-type uint))
  (let
    (
      (facility-id (var-get next-facility-id))
    )
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? facilities { facility-id: facility-id })) ERR-FACILITY-EXISTS)

    (map-set facilities
      { facility-id: facility-id }
      {
        name: name,
        location: location,
        facility-type: facility-type,
        registration-date: block-height
      }
    )

    (var-set next-facility-id (+ facility-id u1))
    (ok facility-id)
  )
)

(define-public (get-facility (facility-id uint))
  (ok (map-get? facilities { facility-id: facility-id }))
)

;; Assessment functions
(define-public (record-assessment (facility-id uint) (compliance-level uint) (findings-count uint))
  (let
    (
      (assessment-id (var-get next-assessment-id))
    )
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? facilities { facility-id: facility-id })) ERR-FACILITY-NOT-FOUND)

    (map-set assessments
      { facility-id: facility-id, assessment-id: assessment-id }
      {
        date: block-height,
        assessor: tx-sender,
        compliance-level: compliance-level,
        findings-count: findings-count
      }
    )

    (var-set next-assessment-id (+ assessment-id u1))
    (ok assessment-id)
  )
)

(define-public (record-finding (assessment-id uint) (finding-id uint) (category uint) (description (string-utf8 200)) (severity uint))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)

    (map-set findings
      { assessment-id: assessment-id, finding-id: finding-id }
      {
        category: category,
        description: description,
        severity: severity
      }
    )

    (ok true)
  )
)

(define-public (get-assessment (facility-id uint) (assessment-id uint))
  (ok (map-get? assessments { facility-id: facility-id, assessment-id: assessment-id }))
)

(define-public (get-finding (assessment-id uint) (finding-id uint))
  (ok (map-get? findings { assessment-id: assessment-id, finding-id: finding-id }))
)

;; Admin functions
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (var-set admin new-admin)
    (ok true)
  )
)

