using AceTaxis.Data.Models;
using AceTaxis.DTOs;
using AceTaxis.DTOs.Admin;
using AceTaxis.DTOs.Booking;
using AceTaxis.DTOs.MessageTemplates;
using AutoMapper;

namespace AceTaxis.Configuration
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
