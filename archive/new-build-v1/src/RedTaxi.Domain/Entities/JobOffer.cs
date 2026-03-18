using System;
using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class JobOffer
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public int UserId { get; set; }
    public Guid OfferGuid { get; set; }
    public DateTime OfferedAt { get; set; }
    public DateTime? RespondedAt { get; set; }
    public AppJobOffer? Response { get; set; }
    public SendMessageOfType Channel { get; set; }
    public int AttemptNumber { get; set; } = 1;
}
