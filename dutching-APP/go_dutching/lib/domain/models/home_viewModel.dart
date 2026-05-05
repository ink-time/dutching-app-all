
// class HomeViewModel {
//     HomeViewModel({
//         required BookingRepository bookingRepository,
//         required UserRepository userRepository,
//     }) :
//     // Repositories are manually assigned because they're private members.
//         _bookingRepository = bookingRepository,
//         _userRepository = userRepository;

//     final BookingRepository _bookingRepository;
//     final UserRepository _userRepository;

//     User? _user;
//     User? get user => _user;

//     List<BookingSummary> _bookings = [];

//     // Items in an [UnmodifiableListView] can't be directly modified,
//     // but changes in the source list can be modified. Since _bookings
//     // is private and bookings is not, the view has no way to modify the
//     // list directly.
//     UnmodifiableListView<BookingSummary> get bookings => UnmodifiableListView(_bookings);
// }