import 'package:flutter/material.dart';
import '../../domain/entities/shopping_item.dart';

class ShoppingListItemWidget extends StatefulWidget {
  final ShoppingItem item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  
  const ShoppingListItemWidget({
    super.key,
    required this.item,
    required this.onTap,
    this.onDelete,
  });
  
  @override
  State<ShoppingListItemWidget> createState() => _ShoppingListItemWidgetState();
}

class _ShoppingListItemWidgetState extends State<ShoppingListItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.item.isCompleted) {
      _animationController.forward();
    }
  }
  
  @override
  void didUpdateWidget(ShoppingListItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.isCompleted != oldWidget.item.isCompleted) {
      if (widget.item.isCompleted) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Dismissible(
          key: Key(widget.item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => widget.onDelete?.call(),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: widget.item.isCompleted
                  ? Colors.grey[100]
                  : Colors.transparent,
            ),
            child: ListTile(
              leading: Checkbox(
                value: widget.item.isCompleted,
                onChanged: (_) => widget.onTap(),
              ),
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  decoration: widget.item.isCompleted 
                      ? TextDecoration.lineThrough 
                      : TextDecoration.none,
                  color: widget.item.isCompleted 
                      ? Colors.grey[600]
                      : null,
                  fontSize: 16,
                ),
                child: Text(widget.item.name),
              ),
              subtitle: widget.item.quantity > 1 
                  ? Text('Количество: ${widget.item.quantity}')
                  : null,
              trailing: widget.item.category != null
                  ? Chip(
                      label: Text(
                        widget.item.category!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      padding: EdgeInsets.zero,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

