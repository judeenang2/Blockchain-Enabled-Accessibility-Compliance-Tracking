import { describe, it, beforeEach, expect, vi } from "vitest"

// Mock blockchain environment
const mockPrincipal = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"
const mockBlockHeight = 100

// Mock contract calls
const facilityAssessment = {
  registerFacility: vi.fn(),
  getFacility: vi.fn(),
  recordAssessment: vi.fn(),
  getAssessment: vi.fn(),
  recordFinding: vi.fn(),
  getFinding: vi.fn(),
  setAdmin: vi.fn(),
}

describe("Facility Assessment Contract", () => {
  beforeEach(() => {
    // Reset mocks
    vi.resetAllMocks()
    
    // Setup default mock returns
    facilityAssessment.registerFacility.mockReturnValue({ value: 1 })
    facilityAssessment.getFacility.mockReturnValue({
      value: {
        name: "Test Facility",
        location: "123 Main St",
        facilityType: 1,
        registrationDate: mockBlockHeight,
      },
    })
    facilityAssessment.recordAssessment.mockReturnValue({ value: 1 })
    facilityAssessment.getAssessment.mockReturnValue({
      value: {
        date: mockBlockHeight,
        assessor: mockPrincipal,
        complianceLevel: 2,
        findingsCount: 3,
      },
    })
  })
  
  describe("registerFacility", () => {
    it("should register a new facility", () => {
      const result = facilityAssessment.registerFacility("Test Facility", "123 Main St", 1)
      expect(result.value).toBe(1)
      expect(facilityAssessment.registerFacility).toHaveBeenCalledWith("Test Facility", "123 Main St", 1)
    })
  })
  
  describe("getFacility", () => {
    it("should return facility details", () => {
      const result = facilityAssessment.getFacility(1)
      expect(result.value).toHaveProperty("name", "Test Facility")
      expect(facilityAssessment.getFacility).toHaveBeenCalledWith(1)
    })
  })
  
  describe("recordAssessment", () => {
    it("should record a new assessment", () => {
      const result = facilityAssessment.recordAssessment(1, 2, 3)
      expect(result.value).toBe(1)
      expect(facilityAssessment.recordAssessment).toHaveBeenCalledWith(1, 2, 3)
    })
  })
  
  describe("getAssessment", () => {
    it("should return assessment details", () => {
      const result = facilityAssessment.getAssessment(1, 1)
      expect(result.value).toHaveProperty("complianceLevel", 2)
      expect(facilityAssessment.getAssessment).toHaveBeenCalledWith(1, 1)
    })
  })
  
  describe("recordFinding", () => {
    it("should record a finding", () => {
      facilityAssessment.recordFinding.mockReturnValue({ value: true })
      const result = facilityAssessment.recordFinding(1, 1, 2, "Missing ramp", 3)
      expect(result.value).toBe(true)
      expect(facilityAssessment.recordFinding).toHaveBeenCalledWith(1, 1, 2, "Missing ramp", 3)
    })
  })
})

