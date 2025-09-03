#include "extend.h"

typedef unsigned long dword;
typedef struct node *ptrnode;

struct node
{
    struct node *parent, *include, *exclude;
    quant timeleft, priority;
    char dir;
};

struct sinfo
{
    quant duur, pri;
} *info;

dword nodes=0;
quant vals;          /* Nr. of items */
char *solution,last; /* String were we place the 0/1 string in */
ptrnode best_time, best_pri, root;

ptrnode alloc_node(quant ttime, quant priority, ptrnode parent, char dir);
int build_tree(quant item, ptrnode current);
void traverse_tree(ptrnode node);
void kill_tree(ptrnode node);
void check_improvement(ptrnode current);

CLIPPER optimize()
{
    quant ttime, i, opttime;
    char *str;

    vals = (quant)(ALENGTH(1));
    opttime = _parl(4);

    info=(struct sinfo *)_exmgrab(sizeof(struct sinfo)*vals);
    solution=(char *)_exmgrab(sizeof(char)*vals+1);

    for (i=0; i < vals; i++)
    {
        info[i].duur = _parnl(1,i+1);
        info[i].pri  = _parnl(2,i+1);
    }
    best_time = NULL;
    best_pri = NULL;
    root = alloc_node((quant)_parnl(3),0L,NULL,'*');
    build_tree(0L, root);

    printf("Best time : %u %u\n",best_time->timeleft, best_time->priority);
    printf("Best prio : %u %u\n",best_pri->timeleft, best_pri->priority);
    printf("Nodes     : %u",nodes);

    kill_tree(root);

    _xfree(info);

    last=0;
    if (opttime)
       traverse_tree(best_time);
    else
       traverse_tree(best_pri);
    solution[last]=NIL;
    strrev(solution);
    str=(char *)_exmgrab(sizeof(char)*last+1);
    strcpy(str,solution);
    _exmback(solution,(sizeof(char)*vals+1));
    _retc(str);
}

void kill_tree(ptrnode node)
{
    if (node != NULL)
    {
        /* Terminate children */
        kill_tree(node->include);
        kill_tree(node->exclude);

        /* Self destruct */
        _exmback(node, sizeof(struct node));
    }
}


ptrnode alloc_node(quant ttime, quant priority, ptrnode parent, char dir)
{
    struct node *create;
    create = (struct node *)_exmgrab(sizeof(struct node));
    create->timeleft = ttime;
    create->priority = priority;
    create->parent = parent;
    create->dir = dir;
    nodes++;
    return(create);
}

void traverse_tree(ptrnode root)
{
    if (root->parent != NULL)
    {
        solution[last++]=root->dir;
        traverse_tree(root->parent);
    }
}

void check_improvement(ptrnode current)
{
    if (best_time!=NULL)
    {
        if ((best_time->timeleft > current->timeleft) || ((best_time->timeleft == current->timeleft) && (best_time->priority < current->priority)))
        {
              best_time = current;
        }
    }
    else
    {
       best_time = current;
    }
    if (best_pri!=NULL)
    {
        if ((best_pri->priority < current->priority) || ((best_pri->priority == current->priority) && (best_pri->timeleft > current->timeleft)))
        {
            best_pri = current;
        }
    }
    else
    {
       best_pri = current;
    }
}

/* Returns : the build tree results in a better solution ... */
int build_tree(quant item, ptrnode current)
{
    ptrnode nt=best_time, np=best_pri;

    if ((item < vals) && (current->timeleft > 0))
    {
        if (info[item].duur <= current->timeleft)
        {
           /* Check if adding this node improves the situation. If not, then
              adding the nodes 'below' will certainly not improve it ... */
           current->include = alloc_node(current->timeleft-info[item].duur,current->priority+info[item].pri,current,'1');
           check_improvement(current->include);
           if (build_tree(item+1,current->include))
           ;
           else
           {
              kill_tree(current->include);
              current->include = NULL;
           }
        }
        else
           current->include = NULL;
        current->exclude = alloc_node(current->timeleft,current->priority,current,'0');
        if (build_tree(item+1,current->exclude))
        ;
        else
        {
            kill_tree(current->exclude);
            current->exclude = NULL;
        }
    }
    else
    {
        current->include = NULL;
        current->exclude = NULL;
    }
    return (~((best_time == nt) && (best_pri == np)));
}

