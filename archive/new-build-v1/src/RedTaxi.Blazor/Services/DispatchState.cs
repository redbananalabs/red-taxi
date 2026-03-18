namespace RedTaxi.Blazor.Services;

using RedTaxi.Shared.DTOs;

public class DispatchState
{
    // Selected items
    public BookingDto? SelectedBooking { get; private set; }
    public DriverDto? SelectedDriver { get; private set; }

    // Panel visibility
    public bool IsBookingFormOpen { get; private set; }
    public bool IsBookingDetailOpen { get; private set; }
    public bool IsDriverDetailOpen { get; private set; }
    public bool IsCommandPaletteOpen { get; private set; }
    public bool IsDriverSelectorOpen { get; private set; }
    public bool IsTimelineExpanded { get; private set; }

    // Filter state
    public DateTime SelectedDate { get; private set; } = DateTime.Today;
    public string? StatusFilter { get; private set; }
    public string? SearchQuery { get; private set; }

    // Events
    public event Action? OnChange;

    private void NotifyStateChanged() => OnChange?.Invoke();

    public void SelectBooking(BookingDto? booking)
    {
        SelectedBooking = booking;
        IsBookingDetailOpen = booking != null;
        IsDriverDetailOpen = false;
        NotifyStateChanged();
    }

    public void SelectDriver(DriverDto? driver)
    {
        SelectedDriver = driver;
        IsDriverDetailOpen = driver != null;
        IsBookingDetailOpen = false;
        NotifyStateChanged();
    }

    public void OpenBookingForm()
    {
        IsBookingFormOpen = true;
        NotifyStateChanged();
    }

    public void CloseBookingForm()
    {
        IsBookingFormOpen = false;
        NotifyStateChanged();
    }

    public void CloseBookingDetail()
    {
        IsBookingDetailOpen = false;
        SelectedBooking = null;
        NotifyStateChanged();
    }

    public void CloseDriverDetail()
    {
        IsDriverDetailOpen = false;
        SelectedDriver = null;
        NotifyStateChanged();
    }

    public void ToggleCommandPalette()
    {
        IsCommandPaletteOpen = !IsCommandPaletteOpen;
        NotifyStateChanged();
    }

    public void CloseCommandPalette()
    {
        IsCommandPaletteOpen = false;
        NotifyStateChanged();
    }

    public void OpenDriverSelector()
    {
        IsDriverSelectorOpen = true;
        NotifyStateChanged();
    }

    public void CloseDriverSelector()
    {
        IsDriverSelectorOpen = false;
        NotifyStateChanged();
    }

    public void ToggleTimeline()
    {
        IsTimelineExpanded = !IsTimelineExpanded;
        NotifyStateChanged();
    }

    public void SetDate(DateTime date)
    {
        SelectedDate = date;
        NotifyStateChanged();
    }

    public void SetStatusFilter(string? status)
    {
        StatusFilter = status;
        NotifyStateChanged();
    }

    public void SetSearchQuery(string? query)
    {
        SearchQuery = query;
        NotifyStateChanged();
    }

    public void CloseAllPanels()
    {
        IsBookingFormOpen = false;
        IsBookingDetailOpen = false;
        IsDriverDetailOpen = false;
        IsCommandPaletteOpen = false;
        IsDriverSelectorOpen = false;
        SelectedBooking = null;
        SelectedDriver = null;
        NotifyStateChanged();
    }
}
