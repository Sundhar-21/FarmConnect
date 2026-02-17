import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/core/services/voice_service.dart';
import 'package:farmconnect/features/consumer/data/navigation_provider.dart';
import 'package:farmconnect/features/consumer/data/product_provider.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';

class VoiceCommandHandler {
  final Ref ref;
  final VoiceService voiceService;

  VoiceCommandHandler(this.ref, this.voiceService);

  Future<void> handleCommand(String command) async {
    final lowerCommand = command.toLowerCase();
    
    if (_matchCommand(lowerCommand, ['go to home', 'open home', 'show home', 'home'])) {
      ref.read(navigationIndexProvider.notifier).state = 0;
      await voiceService.speak('Opening home screen');
      return;
    }

    if (_matchCommand(lowerCommand, ['go to search', 'open search', 'search', 'find'])) {
      ref.read(navigationIndexProvider.notifier).state = 1;
      await voiceService.speak('Opening search. What would you like to find?');
      return;
    }

    if (_matchCommand(lowerCommand, ['go to favorites', 'open favorites', 'my favorites', 'favourites', 'favorites'])) {
      ref.read(navigationIndexProvider.notifier).state = 2;
      await voiceService.speak('Opening favorites');
      return;
    }

    if (_matchCommand(lowerCommand, ['go to cart', 'open cart', 'my cart', 'shopping cart', 'basket'])) {
      ref.read(navigationIndexProvider.notifier).state = 3;
      await voiceService.speak('Opening cart');
      return;
    }

    if (_matchCommand(lowerCommand, ['go to profile', 'open profile', 'my account', 'account', 'profile'])) {
      ref.read(navigationIndexProvider.notifier).state = 4;
      await voiceService.speak('Opening profile');
      return;
    }

    if (_matchCommand(lowerCommand, ['search for', 'find', 'look for', 'show me'])) {
      final searchTerm = _extractSearchTerm(lowerCommand);
      if (searchTerm.isNotEmpty) {
        await _searchAndAddToCart(searchTerm);
        return;
      }
    }

    if (_matchCommand(lowerCommand, ['add to cart', 'buy', 'purchase', 'add'])) {
      final productName = _extractProductName(lowerCommand);
      if (productName.isNotEmpty) {
        await _addProductToCart(productName);
        return;
      }
    }

    if (_matchCommand(lowerCommand, ['clear cart', 'empty cart', 'remove all'])) {
      ref.read(cartProvider.notifier).clearCart();
      await voiceService.speak('Cart cleared');
      return;
    }

    if (_matchCommand(lowerCommand, ['how much', 'total', 'price', 'cost'])) {
      final cart = ref.read(cartProvider);
      final total = cart.fold(0.0, (sum, item) => sum + (item.product['price'] * item.quantity));
      await voiceService.speak('Your total is ${total.toStringAsFixed(2)} rupees');
      return;
    }

    if (_matchCommand(lowerCommand, ['how many items', 'items in cart', 'cart items'])) {
      final cart = ref.read(cartProvider);
      final count = cart.fold(0, (sum, item) => sum + item.quantity);
      await voiceService.speak('You have $count items in your cart');
      return;
    }

    if (_matchCommand(lowerCommand, ['help', 'commands', 'what can you do'])) {
      await voiceService.speak('I can help you navigate to home, search, favorites, cart, or profile. I can also search for products and add them to your cart. Just say hey nova followed by your command.');
      return;
    }

    await voiceService.speak('Sorry, I did not understand that command. Say hey nova and then tell me what you want to do.');
  }

  bool _matchCommand(String command, List<String> patterns) {
    return patterns.any((pattern) => command.contains(pattern));
  }

  String _extractSearchTerm(String command) {
    final patterns = ['search for ', 'find ', 'look for ', 'show me '];
    for (final pattern in patterns) {
      if (command.contains(pattern)) {
        return command.split(pattern).last.trim();
      }
    }
    return command.trim();
  }

  String _extractProductName(String command) {
    final patterns = ['add to cart ', 'buy ', 'purchase ', 'add '];
    for (final pattern in patterns) {
      if (command.contains(pattern)) {
        return command.split(pattern).last.trim();
      }
    }
    return command.replaceAll(RegExp(r'\d+'), '').trim();
  }

  Future<void> _searchAndAddToCart(String searchTerm) async {
    ref.read(navigationIndexProvider.notifier).state = 1;
    
    final productsAsync = ref.read(productsProvider);
    productsAsync.whenData((products) {
      final matchingProducts = products.where((p) {
        final name = (p['name'] as String).toLowerCase();
        return name.contains(searchTerm.toLowerCase());
      }).toList();

      if (matchingProducts.isNotEmpty) {
        final product = matchingProducts.first;
        ref.read(cartProvider.notifier).addToCart(product, 1);
        voiceService.speak('Found ${matchingProducts.length} products for $searchTerm. Added ${product['name']} to your cart');
      } else {
        voiceService.speak('No products found for $searchTerm');
      }
    });
  }

  Future<void> _addProductToCart(String productName) async {
    final productsAsync = ref.read(productsProvider);
    productsAsync.whenData((products) {
      final matchingProducts = products.where((p) {
        final name = (p['name'] as String).toLowerCase();
        return name.contains(productName.toLowerCase());
      }).toList();

      if (matchingProducts.isNotEmpty) {
        final product = matchingProducts.first;
        ref.read(cartProvider.notifier).addToCart(product, 1);
        voiceService.speak('Added ${product['name']} to your cart');
      } else {
        voiceService.speak('Product $productName not found');
      }
    });
  }
}

final voiceCommandHandlerProvider = Provider<VoiceCommandHandler>((ref) {
  final voiceService = ref.watch(voiceServiceProvider.notifier);
  return VoiceCommandHandler(ref, voiceService);
});
