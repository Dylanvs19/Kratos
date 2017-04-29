# Kratos

### Conventions

---

<details><summary>UITableViewCells</summary><p>

> Each tableViewCell should have a string static variable named `identifier`. This should be a string defined as such: 

```

class TableViewCell: UITableViewCell { 
  static let identifier = String(describing: TableViewCell.self) 
}

```

</p></details>

---
