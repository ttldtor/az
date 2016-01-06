module az.core.model;

import std.variant;
import std.conv;
import std.traits;

import az.core.az;
import az.core.role;
import az.core.handler;

abstract class Model: Az {
    this(Az parent = null) {
        super(parent);
    }

    @property int rowCount(const ModelIndex parent = new ModelIndex()) const;
    @property int columnCount(const ModelIndex parent = new ModelIndex()) const;

    Variant data(const ModelIndex index, Role role = Role.Display) const;
    bool setData(const ModelIndex index, Variant value, Role role = Role.Edit);

    ModelIndex index(int row, int column, const ModelIndex parent = new ModelIndex()) const;
    ModelIndex parentIndex(const ModelIndex child = new ModelIndex()) const;

    const(ModelIndex) siblingIndex(int row, int column, const ModelIndex index) const{
        if (row == index.row && column == index.column) {
            return index;
        } else {
            return this.index(row, column, parentIndex(index));
        }
    }

    protected ModelIndex createIndex(int row, int column) const {
        return new ModelIndex(row, column, this);
    }

    bool hasIndex(int row, int column, const ModelIndex parent = new ModelIndex()) const {
        if (row < 0 || column < 0) {
            return false;
        }

        return row < rowCount(parent) && column < columnCount(parent);
    }

    /**
     * See QAbstractItemModel::hasChildren. Returns true if parent has any children
     */

    bool hasDerivedIndicies(const ModelIndex parent) const {
        return rowCount(parent) > 0 && columnCount(parent) > 0;
    }

    /**
     * Returns a map with values for all predefined roles in the model for the item at the given $(D_PARAM index).
     */

    Variant[Role] itemData(const ModelIndex index) const {
        Variant[Role] result;

        foreach(i, role; EnumMembers!Role) {
            Variant d = data(index, role);

            if(d.hasValue) {
                result[role] = d;
            }
        }

        return result;
    }

    bool setItemData(const ModelIndex index, const Variant[Role] roles) {
        bool result = true;

        foreach(Role role, Variant value; roles) {
            result = result && setData(index, value, role);
        }

        return result;
    }

    /+Handlers+/

    auto dataChanged = new SharedHandler!(const ModelIndex /+ topLeft +/, const ModelIndex /+ bottomRight +/, const(Role[]) /+roles+/)();
    auto beginResetModel = new SharedHandler!();
    auto endResetModel = new SharedHandler!();

    auto beginInsertRows = new SharedHandler!(const ModelIndex /+ parent +/, int /+ first +/, int /+ last +/);
    auto endInsertRows = new SharedHandler!();

    auto beginRemoveRows = new SharedHandler!(const ModelIndex /+ parent +/, int /+ first +/, int /+ last +/);
    auto endRemoveRows = new SharedHandler!();

    auto beginInsertColumns = new SharedHandler!(const ModelIndex /+ parent +/, int /+ first +/, int /+ last +/);
    auto endInsertColumns = new SharedHandler!();
    
    auto beginRemoveColumns = new SharedHandler!(const ModelIndex /+ parent +/, int /+ first +/, int /+ last +/);
    auto endRemoveColumns = new SharedHandler!();
};

unittest {
    //Model m = new Model();
}

class ModelIndex: Az {
    private const(Model) model_;
    private int row_;
    private int column_;

    public this() {
        row_ = -1;
        column_ = -1;
        model_ = null;
    }

    private this(int row, int column, const Model model) {
        row_ = row;
        column_ = column;
        model_ = model;
    }
    
    @property int column() const {
        return column_;
    }
    
    @property int row() const {
        return row_;
    }
    
    @property ModelIndex child(int row, int column) const {
        if (model !is null) {
            return model_.index(row, column, this);
        } else {
            return new ModelIndex();
        }
    }
    
    @property ModelIndex parentIndex() const {
        if (model_ !is null) {
            return model_.parentIndex(this);
        } else {
           return new ModelIndex();
        }
    }
    
    @property const(ModelIndex) siblingIndex(int row, int column) const {
        if (model_ !is null) {
            if (row == row_ && column == column_) {
                return this;
            } else {
                return model_.siblingIndex(row, column, this);
            }
        } else {
            return new ModelIndex();
        }
    }
    
    @property const(Model) model() const {
        return model_;
    }

    @property Variant data() const {
        if (model_ !is null) {
            return model_.data(this);
        } else {
            return Variant();
        }
    }

    @property bool isValid() const {
        return row_ >= 0 && column_ >= 0 && model_ !is null;
    }

    override bool opEquals(Object o) {
        const i = o.to!(const ModelIndex);

        return row_ == i.row && column_ == i.column && model_ is i.model;
    }

    override string toString() const {
        import std.format: format;

        return format("ModelIndex [row = %s, column = %s, model = %s]", row_, column_, &model_);
    }
}

unittest {
    assert(new ModelIndex().isValid == false);
}

alias ModelIndexList = ModelIndex[];