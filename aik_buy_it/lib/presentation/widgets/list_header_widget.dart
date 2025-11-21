import 'package:flutter/material.dart';
import '../../domain/entities/shopping_list.dart';

class ListHeaderWidget extends StatelessWidget {
  final ShoppingList list;
  
  const ListHeaderWidget({
    super.key,
    required this.list,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            list.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (list.description != null) ...[
            const SizedBox(height: 8),
            Text(
              list.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                icon: Icons.shopping_cart,
                label: 'Всего: ${list.totalItems}',
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: Icons.check_circle,
                label: 'Куплено: ${list.completedItems}',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  
  const _StatChip({
    required this.icon,
    required this.label,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

