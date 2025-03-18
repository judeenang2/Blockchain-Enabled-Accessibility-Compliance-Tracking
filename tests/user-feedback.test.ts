import { describe, it, beforeEach, expect, vi } from "vitest"

// Mock blockchain environment
const mockPrincipal = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"
const mockBlockHeight = 100

// Mock contract calls
const userFeedback = {
  submitFeedback: vi.fn(),
  getFeedback: vi.fn(),
  getCategoryRating: vi.fn(),
  calculateAverageRating: vi.fn(),
  setAdmin: vi.fn(),
}

describe("User Feedback Contract", () => {
  beforeEach(() => {
    // Reset mocks
    vi.resetAllMocks()
    
    // Setup default mock returns
    userFeedback.submitFeedback.mockReturnValue({ value: 1 })
    userFeedback.getFeedback.mockReturnValue({
      value: {
        facilityId: 1,
        user: mockPrincipal,
        date: mockBlockHeight,
        category: 1,
        rating: 4,
        comments: "Good wheelchair access but could use better signage",
      },
    })
    userFeedback.getCategoryRating.mockReturnValue({
      value: {
        totalRatings: 5,
        sumRatings: 20,
        lastUpdated: mockBlockHeight,
      },
    })
    userFeedback.calculateAverageRating.mockReturnValue({ value: 4 })
  })
  
  describe("submitFeedback", () => {
    it("should submit new feedback", () => {
      const result = userFeedback.submitFeedback(1, 1, 4, "Good wheelchair access but could use better signage")
      expect(result.value).toBe(1)
      expect(userFeedback.submitFeedback).toHaveBeenCalledWith(
          1,
          1,
          4,
          "Good wheelchair access but could use better signage",
      )
    })
  })
  
  describe("getFeedback", () => {
    it("should return feedback details", () => {
      const result = userFeedback.getFeedback(1)
      expect(result.value).toHaveProperty("rating", 4)
      expect(userFeedback.getFeedback).toHaveBeenCalledWith(1)
    })
  })
  
  describe("getCategoryRating", () => {
    it("should return category rating statistics", () => {
      const result = userFeedback.getCategoryRating(1, 1)
      expect(result.value).toHaveProperty("totalRatings", 5)
      expect(userFeedback.getCategoryRating).toHaveBeenCalledWith(1, 1)
    })
  })
  
  describe("calculateAverageRating", () => {
    it("should calculate the average rating for a category", () => {
      const result = userFeedback.calculateAverageRating(1, 1)
      expect(result.value).toBe(4)
      expect(userFeedback.calculateAverageRating).toHaveBeenCalledWith(1, 1)
    })
  })
})

