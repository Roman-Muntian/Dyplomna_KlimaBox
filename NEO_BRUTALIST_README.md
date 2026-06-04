# KlimaBox — Neo-Brutalist Design System

Документація дизайн-системи для розробників.

---

## Токени дизайну

| Токен | Значення |
|-------|----------|
| Фон (paper) | `#F4F4F4` |
| Чорнило (ink) | `#000000` |
| Акцент жовтий | `#FFF000` |
| Акцент синій | `#0055FF` |
| Акцент м'ятний | `#00FF90` |
| Аларм червоний | `#FF3D2E` |
| Рамка | **2.5 px** суцільна чорна |
| Тінь | `offset (5, 5)` · `blur 0` · `#000000` |
| Радіус | `0 px` (гострий) або **12 px** (chunky) |
| Шрифт display | **Unbounded** |
| Шрифт body/label | **Manrope** |
| Шрифт числа | **JetBrains Mono** |

При натисканні кнопки тінь зникає і елемент зміщується на `+5px / +5px` — імітація фізичного натискання.

---

## Де знаходяться токени

**Flutter** — `lib/theme/neo_brutalist_theme.dart`

```dart
NB.paper        // фон
NB.ink          // рамки і текст
NB.neonYellow   // жовтий акцент
NB.electricBlue // синій акцент
NB.mintGreen    // м'ятний акцент
NB.hotRed       // аларм

nbBlock(color: ..., shadow: ...) // декорація блока
```

---

## Компоненти

Всі UI компоненти — в `lib/widgets/`:

| Компонент | Файл | Призначення |
|-----------|------|-------------|
| `NeoButton` | `neo_button.dart` | Кнопка з анімацією натискання |
| `NeoCard` | `neo_card.dart` | Картка з рамкою і тінню |
| `NeoTag` | `neo_decorations.dart` | Кольоровий тег (error/info/success/warn) |
| `NeoIconBox` | `neo_decorations.dart` | Квадратна іконка у рамці |
| `NeoSectionHeader` | `neo_decorations.dart` | Заголовок секції з лінією |
| `NeoStripeBackground` | `neo_decorations.dart` | Діагональний смугастий фон |
| `BrutalistToggle` | `toggle.dart` | Перемикач двох станів |
| `BrutalistRangeSlider` | `range_slider.dart` | Повзунок діапазону |