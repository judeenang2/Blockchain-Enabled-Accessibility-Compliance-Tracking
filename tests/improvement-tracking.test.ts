import { describe, it, beforeEach, expect, vi } from "vitest"

// Mock blockchain environment
const mockPrincipal = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"
const mockBlockHeight = 100

// Mock contract calls
const improvementTracking = {
  createImprovementPlan: vi.fn(),
  updateImprovementStatus: vi.fn(),
  getImprovement: vi.fn(),
  getImprovementUpdate: vi.fn(),
  setAdmin: vi.fn(),
}

describe("Improvement Tracking Contract", () => {
  beforeEach(() => {
    // Reset mocks
    vi.resetAllMocks()
    
    // Setup default mock returns
    improvementTracking.createImprovementPlan.mockReturnValue({ value: 1 })
    improvementTracking.updateImprovementStatus.mockReturnValue({ value: true })
    improvementTracking.getImprovement.mockReturnValue({
      value: {
        facilityId: 1,
        findingId: 2,
        description: "Install wheelchair ramp",
        status: 2, // In progress
        createdAt: mockBlockHeight,
        targetDate: mockBlockHeight + 100,
        completedDate: 0,
        assignedTo: mockPrincipal,
      },
    })
    improvementTracking.getImprovementUpdate.mockReturnValue({
      value: {
        date: mockBlockHeight,
        status: 2,
        notes: "Materials ordered",
        updatedBy: mockPrincipal,
      },
    })
  })
  
  describe("createImprovementPlan", () => {
    it("should create a new improvement plan", () => {
      const targetDate = mockBlockHeight + 100
      const result = improvementTracking.createImprovementPlan(
          1,
          2,
          "Install wheelchair ramp",
          targetDate,
          mockPrincipal,
      )
      expect(result.value).toBe(1)
      expect(improvementTracking.createImprovementPlan).toHaveBeenCalledWith(
          1,
          2,
          "Install wheelchair ramp",
          targetDate,
          mockPrincipal,
      )
    })
  })
  
  describe("updateImprovementStatus", () => {
    it("should update the status of an improvement", () => {
      const result = improvementTracking.updateImprovementStatus(1, 2, "Materials ordered")
      expect(result.value).toBe(true)
      expect(improvementTracking.updateImprovementStatus).toHaveBeenCalledWith(1, 2, "Materials ordered")
    })
  })
  
  describe("getImprovement", () => {
    it("should return improvement details", () => {
      const result = improvementTracking.getImprovement(1)
      expect(result.value).toHaveProperty("description", "Install wheelchair ramp")
      expect(improvementTracking.getImprovement).toHaveBeenCalledWith(1)
    })
  })
  
  describe("getImprovementUpdate", () => {
    it("should return improvement update details", () => {
      const result = improvementTracking.getImprovementUpdate(1, 1)
      expect(result.value).toHaveProperty("notes", "Materials ordered")
      expect(improvementTracking.getImprovementUpdate).toHaveBeenCalledWith(1, 1)
    })
  })
})

