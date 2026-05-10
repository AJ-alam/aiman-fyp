import 'package:flutter/material.dart';
import '../../models/package.dart';
import '../../services/booking_service.dart';
import '../payments/jazzcash_payment_screen.dart';

class CreateBookingScreen extends StatefulWidget {
  final Package package;

  const CreateBookingScreen({super.key, required this.package});

  @override
  _CreateBookingScreenState createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  int _seats = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _paymentMethod = 'CARD';
  bool _isLoading = false;

  final List<String> _paymentMethods = ['CARD', 'JAZZCASH', 'EASYPAISA', 'BANK'];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final double actualPrice = (widget.package.hasDiscount == true)
        ? widget.package.price * (1 - (widget.package.discountPercentage ?? 0) / 100)
        : widget.package.price;
    final totalPrice = actualPrice * _seats;

    if (_paymentMethod == 'JAZZCASH') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JazzCashPaymentScreen(
            package: widget.package,
            seats: _seats,
            amount: totalPrice,
            onPaymentSuccess: () => _finalizeBooking(),
          ),
        ),
      );
    } else {
      _finalizeBooking();
    }
  }

  Future<void> _finalizeBooking() async {
    setState(() => _isLoading = true);

    final result = await BookingService.createBooking(
      packageId: widget.package.id,
      seats: _seats,
      travelDate: _selectedDate.toIso8601String().split('T')[0],
      paymentMethod: _paymentMethod,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      final success = result['success'] as bool;
      final message = result['message'] as String;

      if (success) {
        // Navigate to payment success screen, clearing the booking stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/payment-success',
          (route) => route.settings.name == '/home' || route.isFirst,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double actualPrice = (widget.package.hasDiscount == true)
        ? widget.package.price * (1 - (widget.package.discountPercentage ?? 0) / 100)
        : widget.package.price;
    final totalPrice = actualPrice * _seats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Package'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Package Info
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.package.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.package.location,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                      Text(
                        'PKR ${widget.package.price} per person',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Number of Seats
            const Text(
              'Number of Seats',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _seats > 1 ? () => setState(() => _seats--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_seats',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _seats < widget.package.availableSeats
                      ? () => setState(() => _seats++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                ),
              ],
            ),
            Text(
              '${widget.package.availableSeats} seats available',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Travel Date
            const Text(
              'Travel Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 16),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(_paymentMethods.map((method) {
              return RadioListTile<String>(
                title: Text(method),
                value: method,
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value!),
              );
            }).toList()),
            const SizedBox(height: 24),

            // Total Price
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Price:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'PKR ${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // No seats warning
            if (widget.package.availableSeats == 0)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This package is fully booked. No seats available.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Confirm Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: (_isLoading || widget.package.availableSeats == 0) 
                    ? null 
                    : _createBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.package.availableSeats == 0 
                            ? 'FULLY BOOKED' 
                            : 'CONFIRM BOOKING',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}