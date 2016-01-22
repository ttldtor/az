module az.core.models.listmodel;

import az.core.az;
import az.core.model;

/*
abstract class ListModel: Model {
    this(Az parent = null) {
        super(parent);
    }

    override @property int columnCount(const ModelIndex parent = new ModelIndex()) const {
        return parent.isValid ? 0 : 1;
    }

    override ModelIndex index(int row, int column, const ModelIndex parent = new ModelIndex()) const {
        return hasIndex(row, column, parent) ? createIndex(row, column) : new ModelIndex();
    }

    override ModelIndex parentIndex(const ModelIndex child = new ModelIndex()) const {
        return new ModelIndex();
    }

    override ModelIndex siblingIndex(int row, int column, const ModelIndex index) const {
        return this.index(row, column);
    }
}
*/

