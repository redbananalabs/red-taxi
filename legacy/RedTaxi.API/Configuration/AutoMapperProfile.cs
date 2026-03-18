using RedTaxi.Data.Models;
using RedTaxi.DTOs;
using RedTaxi.DTOs.Admin;
using RedTaxi.DTOs.Booking;
using RedTaxi.DTOs.MessageTemplates;
using AutoMapper;

namespace RedTaxi.Configuration
{
    public class AutoMapperProfile : Profile
    {
        public AutoMapperProfile()
        {
            CreateMap<CreateBookingRequestDto, Booking>();
            CreateMap<UpdateBookingRequestDto, Booking>();

            CreateMap<Booking, PersistedBookingModel>();

            CreateMap<AccountPassengerDto, AccountPassenger>();
            CreateMap<AccountPassenger, AccountPassengerDto>();

            CreateMap<WebBookingDto, WebBooking>();

            CreateMap<DriverOnShift, DriverOnShiftDto>();

            CreateMap<IDriverInvoiceStatement, DriverInvoiceStatementDto>();
            CreateMap<DriverStatementDto, DriverInvoiceStatementDto>();
            CreateMap<DriverExpense, DriverExpenseDto>();
            CreateMap<DriverExpenseDto, DriverExpense>();
            CreateMap<AccountDto, Account>();

            AllowNullCollections = true;
        }
    }
}
