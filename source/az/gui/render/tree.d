module az.gui.render.tree;

import az.core.az;
import std.container;

alias uint GLuint;

/**
 * Class for storing render cache. Contains just texture id.
 *
 */
class RenderNodeCache {
public:

    this()
    {
    }

    this( GLuint textureId )
    {
        index = textureId;
    }

    ~this()
    {
        // TODO: clean texture from GPU memory...
    }

    @property auto texture( GLuint id )
    {
        if( id != index )
            index = id; // do we need to clean old texture?

        return index;
    }

private:
    GLuint index = 0;
}

/**
 * Base class for all kinds of layers.
 *
 */
class RenderTreeNode : Az {

    this(Az parent = null) {
        super(parent);
    }

    auto opIndex( size_t idx )
    {
        return leafs_[ idx ];
    }

    auto size()
    {
        return leafs_.length;
    }

    /+ Review: opApply for foreach over class +/
    int opApply( int delegate( ref RenderTreeNode ) dg ) {
        int result = 0;

        foreach ( leaf; leafs_) {
            result = dg(leaf);

            if ( result != 0 ) {
                break;
            }
        }

        return result;
    }

    /+ Review: or may be we should give them leafs? =3 Please, fix +/
    @property RenderTreeNode[] leafs() {
        return leafs_;
    }

protected:
    RenderNodeCache  cache_;
    RenderTreeNode[] leafs_;
}


/**
 * Interface for tree nodes walker.
 *
 */
interface TreeWalker {
    /+ Review: fix ref +/
    void visit( ref RenderTreeNode value );
}

/**
 * Tree walker that guarantee that the tree won't be changed.
 */
class TreeWalkerConst : TreeWalker {
public:
    /+ Review: fix +/
    override final void visit( ref RenderTreeNode value )
    {
        visitConst( value );
    }

    void visitConst( const ref RenderTreeNode value ) {}
}

/**
 * Class to walk over a tree and render it.
 *
 */
class RenderWalker : TreeWalkerConst {
public:
    override void visitConst( const ref RenderTreeNode value )
    {
        // some render stuff with value...
    }
}

/**
 *
 *
 */
class RenderTree {
public:

    this()
    {
    }

    void traverse( TreeWalker walker )
    {
        ( RenderTreeNode node )
        {
            /+ Review: we should *make* array =3 +/
            auto nodes = make!(Array!RenderTreeNode)( [ node ] );
            while( !nodes.empty ) {
                auto current = nodes.back;
                nodes.stableRemoveBack();

                /+ Review: visit here may be? Please, relocate if it needs +/
                walker.visit( current );

                foreach( child; current ) {

                    /+ Review: array doesn't have stableInsert*() methods +/
                    nodes.insertBack( child ); // replace it with stableInsertFront() maybe
                }
            }
        }( layers_ );
    }

private:
    RenderTreeNode layers_;
}
